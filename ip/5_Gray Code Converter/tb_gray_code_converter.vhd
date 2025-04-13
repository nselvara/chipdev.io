--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 4
--!  @details    VHDL module for Gray Code Converter
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

entity tb_gray_code_converter is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_gray_code_converter is
    constant SIM_TIMEOUT: time := 10 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: integer := 4;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal dout: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');

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
        info("Starting tb_gray_code_converter");

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

        procedure wait_clk_cycles(n: positive) is
        begin
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

        function to_gray_code(value: unsigned) return unsigned is
            variable gray_value: unsigned(value'length - 1 downto 0);
        begin
            gray_value(value'length - 1) := value(value'length - 1);
            for i in value'length - 2 downto 0 loop
                gray_value(i) := value(i) xor value(i + 1);
            end loop;
            return gray_value;
        end function;

        procedure check_gray_code(expected: unsigned) is begin
            check_equal(got => dout, expected => expected, msg => "Gray code value mismatch!");
        end procedure;

        function get_amount_of_changed_bits(a: unsigned; b: unsigned) return natural is
            variable count: natural := 0;
        begin
            for i in a'range loop
                if a(i) /= b(i) then
                    count := count + 1;
                end if;
            end loop;
            return count;
        end function;

        procedure test_gray_counter_by_checking_changed_bits is
            variable dout_reg: dout'subtype := (others => '0');
        begin
            info("1.0) test_gray_counter_by_checking_changed_bits");

            reset_module;
            start_module;

            for i in 0 to 2**dout'length - 1 loop
                dout_reg := dout;
                wait_clk_cycles(1);
                check_equal(got => get_amount_of_changed_bits(a => dout, b => dout_reg), expected => 1, msg => "Changed bits count mismatch! Only one bit should change in Gray code!");
            end loop;
        end procedure;

        procedure test_gray_counter_with_expected is
            variable expected_gray_value: dout'subtype := (others => '0');    
        begin
            info("2.0) test_gray_counter_with_expected");

            reset_module;
            start_module;

            for i in 0 to 2**dout'length - 1 loop
                expected_gray_value := to_gray_code(value => to_unsigned(i, dout'length));
                check_gray_code(expected => expected_gray_value);
                wait_clk_cycles(1);
            end loop;
        end procedure;

        procedure test_gray_counter_randomly is
            variable binary_counter: dout'subtype := (others => '0');
            variable expected_gray_value: dout'subtype := (others => '0');
            variable random_wait_time: natural := 0;
        begin
            info("3.0) test_gray_counter_randomly");

            reset_module;
            start_module;

            for i in 1 to 1000 loop
                random_wait_time := random.RandInt(Min => 1, Max => 10);
                binary_counter := binary_counter + random_wait_time;
                expected_gray_value := to_gray_code(value => binary_counter);
                rst_n <= random.DistSl(RESET_WEIGHT_SEQUENCE);
    
                wait_clk_cycles(random_wait_time);

                if rst_n = '0' then
                    binary_counter := (others => '0');
                    expected_gray_value := (others => '0');
                end if;

                check_gray_code(expected => expected_gray_value);
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        wait_clk_cycles(1);

        while test_suite loop
            if run("test_gray_counter_by_checking_changed_bits") then
                test_gray_counter_by_checking_changed_bits;
            elsif run("test_gray_counter_with_expected") then
                test_gray_counter_with_expected;
            elsif run("test_gray_counter_randomly") then
                test_gray_counter_randomly;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    gray_code_converter_inst: entity work.gray_code_converter
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            dout => dout
        );
end architecture;
