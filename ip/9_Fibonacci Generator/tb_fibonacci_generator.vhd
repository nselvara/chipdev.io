--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 9
--!  @details    VHDL module for Fibonacci Generator
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

entity tb_fibonacci_generator is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_fibonacci_generator is
    constant SIM_TIMEOUT: time := 10 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 32;

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
        info("Starting tb_fibonacci_generator");

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
        constant PROPAGATION_TIME: time := 1 ns;
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

        function get_fibonacci_value(index: natural) return unsigned is
            variable fibonacci_value: dout'subtype;
            variable f_n0: dout'subtype := to_unsigned(1, DATA_WIDTH);
            variable f_n1: dout'subtype := to_unsigned(1, DATA_WIDTH);
        begin
            if index <= 1 then
                fibonacci_value := to_unsigned(1, fibonacci_value'length);
            else
                for i in 2 to index loop
                    fibonacci_value := f_n0 + f_n1;
                    f_n1 := f_n0;
                    f_n0 := fibonacci_value;
                end loop;
            end if;

            return fibonacci_value;
        end function;

        procedure check_dout(index: natural; expected: unsigned) is begin
            check_equal(got => dout, expected => expected, msg => "fibonacci(" & to_string(index) & ")");
        end procedure;

        procedure test_example_1 is
            constant expected_values_1: integer_vector := (1, 1, 2, 3, 5, 8);
            constant expected_values_2: integer_vector := (1, 1, 2, 3, 5);
        begin
            info("1.0) test_example_1 - Fibonacci output before and after reset");
        
            reset_module;
            start_module;
        
            -- First 6 Fibonacci numbers
            for i in expected_values_1'range loop
                wait_clk_cycles(1);
                check_dout(index => i, expected => to_unsigned(expected_values_1(i), dout'length));
            end loop;
        
            -- Apply reset
            reset_module;
            start_module;
        
            -- Next 5 Fibonacci numbers after reset
            for i in expected_values_2'range loop
                wait_clk_cycles(1);
                check_dout(index => i, expected => to_unsigned(expected_values_2(i), dout'length));
            end loop;
        end procedure;

        procedure test_multiple_sequence is
            variable expected_value: dout'subtype;
        begin
            info("2.0) test_multiple_sequence - Random Fibonacci output");
        
            reset_module;
            start_module;

            for i in 0 to 999 loop
                wait_clk_cycles(1);
                expected_value := get_fibonacci_value(index => i);
                check_dout(index => i, expected => expected_value);
            end loop;
        end procedure;

        procedure test_random_wait_and_reset is
            variable random_wait_time: natural := 0;
            variable random_index: natural := 0;
            variable expected_value: dout'subtype;
        begin
            info("3.0) test_random_wait_and_reset - Random Fibonacci output with wait and reset");
        
            reset_module;
            start_module;
            -- Jump straight into the first Fibonacci number
            wait_clk_cycles(1);

            for i in 0 to 999 loop
                random_wait_time := random.RandInt(1, 10);
                random_index := random_index + random_wait_time;
                wait_clk_cycles(random_wait_time);
                expected_value := get_fibonacci_value(index => random_index);
                check_dout(index => i, expected => expected_value);
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);
        
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_multiple_sequence") then
                test_multiple_sequence;
            elsif run("test_random_wait_and_reset") then
                test_random_wait_and_reset;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;
    
    fibonacci_generator_inst: entity work.fibonacci_generator
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            dout => dout
        );
end architecture;
