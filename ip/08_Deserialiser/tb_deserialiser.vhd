--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 8
--!  @details    VHDL module for Deserialiser
--! ----------------------------------------------------------------------------

-- vunit: run_all_in_same_sim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.RandomPType;

use work.tb_utils.all;

entity tb_deserialiser is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_deserialiser is
    constant SIM_TIMEOUT: time := 10 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 6;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din: std_ulogic := '0';
    signal dout: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    signal dout_expected: dout'subtype := (others => '0');
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
        info("Starting tb_deserialiser");

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;
    ------------------------------------------------------------

    dout_expected_proc: process(clk)
    begin
        if rising_edge(clk) then
            dout_expected <= (others => '0') when rst_n = '0' else dout_expected(dout'high - 1 downto 0) & din;
        end if;
    end process;

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
            constant DIN_SEQUENCE: std_ulogic_vector(0 to 7) := "10110011";
        begin
            info("1.0) test_example_1");

            din <= '0';

            reset_module;
            check_equal(got => dout, expected => std_ulogic_vector'(dout'range => '0'), msg => "dout - Reset check");
            start_module;

            for i in DIN_SEQUENCE'low to DIN_SEQUENCE'high loop
                din <= DIN_SEQUENCE(i);
                wait_clk_cycles(1);
                check_equal(got => dout, expected => dout_expected, msg => "dout - Check after din(" & to_string(DIN_SEQUENCE(i)) & ")");
            end loop;
        end procedure;

        procedure test_random is
            variable din_test: dout'subtype := (others => '0');
        begin
            info("2.0) test_random");

            din <= '0';
            reset_module;
            start_module;

            for i in 1 to 1000 loop
                din_test := random.RandSlv(Size => dout'length);

                for i in dout'low to dout'high loop
                    rst_n <= random.DistSl(Weight => RESET_N_WEIGHT);
                    din <= din_test(i);
                    wait_clk_cycles(1);
                    check_equal(got => dout, expected => dout_expected, msg => "dout - Random check");
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
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    deserialiser_inst : entity work.deserialiser
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            dout => dout
        );
end architecture;
