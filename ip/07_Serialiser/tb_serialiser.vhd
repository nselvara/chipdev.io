--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 7
--!  @details    VHDL module for Serialiser
--! ----------------------------------------------------------------------------

-- vunit: run_all_in_same_sim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.RandomPType;
use osvvm.RandomPkg.NaturalVSlType;

use work.tb_utils.all;

entity tb_serialiser is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_serialiser is
    constant SIM_TIMEOUT: time := 10 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 8;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal din_en: std_ulogic := '0';
    signal dout: std_ulogic := '0';

    signal dout_expected: std_ulogic;
    signal simulation_done: boolean := false;
begin
    generate_clock(clk => clk, FREQ => real(1 sec / CLK_PERIOD));

    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_serialiser");

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;
    ------------------------------------------------------------

    checker: process
        variable random: RandomPType;

        procedure wait_clk_cycles(n: positive) is begin
            for i in 1 to n loop
                wait until rising_edge(clk);
            end loop;
            wait for PROPAGATION_TIME;
        end procedure;

        procedure reset_module is begin
            rst_n <= '0';
            wait_clk_cycles(1);
        end procedure;

        procedure start_module is begin
            rst_n <= '1';
        end procedure;

        procedure test_example_1 is
            variable din_val: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := std_ulogic_vector(to_unsigned(16#FB#, DATA_WIDTH));
        begin
            info("1.0) test_example_1: shift 0xFB with enable pulse");

            din_en <= '0';
            reset_module;
            start_module;

            din <= din_val;
            din_en <= '1';
            wait_clk_cycles(1);
            din_en <= '0';
            din <= (others => '0');

            for i in din'low to din'high loop
                wait_clk_cycles(1);
                check_equal(got => dout, expected => din_val(i), msg => "dout");
            end loop;
        end procedure;

        procedure test_example_2 is
            variable din_val: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := std_ulogic_vector(to_unsigned(16#FD#, DATA_WIDTH));
        begin
            info("2.0) test_example_2: hold enable for 3 cycles (restarts)");

            din_en <= '0';
            reset_module;
            start_module;

            din <= din_val;
            din_en <= '1';
            wait_clk_cycles(3);  -- will restart each time

            din_en <= '0';

            for i in din'low to din'high loop
                wait_clk_cycles(1);
                check_equal(got => dout, expected => din_val(i), msg => "dout");
            end loop;
        end procedure;

        procedure test_example_3 is begin
            info("3.0) test_example_3: reset overrides enable");

            din <= std_ulogic_vector(to_unsigned(16#FF#, DATA_WIDTH));
            din_en <= '1';

            reset_module;  -- Force all output to '0'

            for i in 0 to 2 loop
                wait_clk_cycles(1);
                check_equal(got => dout, expected => '0', msg => "dout");
            end loop;

            rst_n <= '1';  -- Release reset
            wait_clk_cycles(1);
            din_en <= '0';
        end procedure;

        procedure test_example_4 is
            variable din_val: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := std_ulogic_vector(to_unsigned(16#FF#, DATA_WIDTH));
        begin
            info("4.0) test_example_4: pad with 0 after all bits");

            din <= din_val;
            din_en <= '1';
            wait_clk_cycles(1);
            din_en <= '0';

            for i in din'low to din'high loop
                wait_clk_cycles(1);
                check_equal(got => dout, expected => din_val(i), msg => "dout");
            end loop;

            for i in 0 to 3 loop -- 4 more cycles of zero padding
                wait_clk_cycles(1);
                check_equal(got => dout, expected => '0', msg => "dout");
            end loop;
        end procedure;

        procedure test_random_pulse is
            variable din_val: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
            variable dout_expected: std_ulogic;

            impure function get_dout_expected(
                din_val: std_ulogic_vector; index: natural; reset: std_ulogic
            ) return std_ulogic is
            begin
                if reset = '0' then
                    return '0';
                elsif index < din_val'length then
                    return din_val(index);
                else
                    return '0';
                end if;
            end function;
        begin
            info("5.0) test_random_pulse");

            reset_module;
            start_module;

            for i in 1 to 10 loop
                din_val := random.RandSlv(Size => DATA_WIDTH);
                din <= din_val;

                rst_n <= '1';
                din_en <= '1';
                wait_clk_cycles(1);
                din_en <= '0';

                for j in 0 to DATA_WIDTH + 2 loop
                    dout_expected := get_dout_expected(din_val, j, rst_n);
                    wait_clk_cycles(1);
                    check_equal(got => dout, expected => dout_expected, msg => "dout(" & to_string(j) & ") (pulse)");
                end loop;
            end loop;
        end procedure;

        procedure test_random_hold is
            constant DIN_EN_WEIGHT_SEQUENCE: NaturalVSlType(std_ulogic'('0') to '1') := ('1' => 99, '0' => 1);

            variable din_en_old: std_ulogic := '0';
            variable din_old: din'subtype := (others => '0');
            variable din_expected: din'subtype := (others => '0');
            variable din_random: din'subtype := (others => '0');

            procedure calculate_expected_loaded_din is begin
                din_expected := (others => '0') when not rst_n else
                                (others => '0') when not din_en and not din_en_old else
                                din_random      when din_en else
                                din_old;
            end procedure;
        begin
            info("6.0) test_random_hold");

            din <= (others => '0');
            reset_module;
            start_module;

            for i in 1 to 1000 loop
                din_en_old := din_en;
                rst_n <= random.DistSl(Weight => RESET_N_WEIGHT);
                din_en <= random.DistSl(Weight => DIN_EN_WEIGHT_SEQUENCE);
                wait_clk_cycles(1);

                din_old := din;
                din_random := random.RandSlv(Size => DATA_WIDTH);
                din <= din_random;

                calculate_expected_loaded_din;

                wait_clk_cycles(n => random.RandInt(1, 4));

                rst_n <= '1';
                din_en <= '0';

                for index in din'low to din'high loop
                    wait_clk_cycles(1);
                    check_equal(got => dout, expected => din_expected(index), msg => "dout = din(" & to_string(index) & ") (hold)");
                end loop;
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_example_2") then
                test_example_2;
            elsif run("test_example_3") then
                test_example_3;
            elsif run("test_example_4") then
                test_example_4;
            elsif run("test_random_pulse") then
                test_random_pulse;
            elsif run("test_random_hold") then
                test_random_hold;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    serialiser_inst : entity work.serialiser
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            din_en => din_en,
            dout => dout
        );
end architecture;
