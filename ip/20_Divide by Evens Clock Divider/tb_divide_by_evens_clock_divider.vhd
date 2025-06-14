--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 20
--!  @details    VHDL module for Divide by Evens Clock Divider
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

entity tb_divide_by_evens_clock_divider is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_divide_by_evens_clock_divider is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 24 ns; -- We take value that's evenly divisible by 6
    constant CLK_FREQ: real := real(1 sec / CLK_PERIOD);
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal clk_div_2, clk_div_4, clk_div_6: std_ulogic;

    signal expected_clk_div_2, expected_clk_div_4, expected_clk_div_6: std_ulogic := '1';
    signal simulation_done: boolean := false;
begin
    generate_clock(clk, CLK_FREQ);
    generate_derived_clock(clk, rst_n, expected_clk_div_2, 2);
    generate_derived_clock(clk, rst_n, expected_clk_div_4, 4);
    generate_derived_clock(clk, rst_n, expected_clk_div_6, 6);

    ------------------------------------------------------------                                               
    -- VUnit
    ------------------------------------------------------------                                        
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_divide_by_evens_clock_divider");

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;
                                                                

    checker: process
        constant PROPAGATION_TIME: time := 1 ns;
        variable random: RandomPType;
        variable expected_clk_div_2_v, expected_clk_div_4_v, expected_clk_div_6_v: std_ulogic := '0';

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
            wait_clk_cycles(1);
        end procedure;

        procedure test_example_1 is
            constant RESET_N_SEQUENCE: std_ulogic_vector := "01111111011111111";
            constant EXPECTED_CLK_DIV_2_SEQUENCE: std_ulogic_vector := "01010101010101010";
            constant EXPECTED_CLK_DIV_4_SEQUENCE: std_ulogic_vector := "01100110011001100";
            constant EXPECTED_CLK_DIV_6_SEQUENCE: std_ulogic_vector := "01110001011100011";
        begin
            info("1.0) test_example_1");

            for i in RESET_N_SEQUENCE'low to RESET_N_SEQUENCE'high loop
                rst_n <= RESET_N_SEQUENCE(i);
                wait_clk_cycles(1);
                expected_clk_div_2_v := EXPECTED_CLK_DIV_2_SEQUENCE(i);
                expected_clk_div_4_v := EXPECTED_CLK_DIV_4_SEQUENCE(i);
                expected_clk_div_6_v := EXPECTED_CLK_DIV_6_SEQUENCE(i);
                debug("i: " & to_string(i) & " rst_n: " & to_string(rst_n) & LF &
                    " clk_div_2: " & to_string(clk_div_2) & LF &
                    " clk_div_4: " & to_string(clk_div_4) & LF &
                    " clk_div_6: " & to_string(clk_div_6));
                check_equal(got => clk_div_2, expected => expected_clk_div_2_v, msg => "clk_div_2 @ cycle " & to_string(i));
                check_equal(got => clk_div_4, expected => expected_clk_div_4_v, msg => "clk_div_4 @ cycle " & to_string(i));
                check_equal(got => clk_div_6, expected => expected_clk_div_6_v, msg => "clk_div_6 @ cycle " & to_string(i));
            end loop;
        end procedure;

        procedure test_random is begin
            info("2.0) test_random - Clock dividers with enable");

            reset_module;
            start_module;

            for i in 1 to 1000 loop
                wait_clk_cycles(1);

                -- Randomly glitch reset_n
                rst_n <= random.DistSl(Weight => RESET_N_WEIGHT);

                -- Check outputs
                check_equal(got => clk_div_2, expected => expected_clk_div_2, msg => "clk_2 @ cycle " & to_string(i));
                check_equal(got => clk_div_4, expected => expected_clk_div_4, msg => "clk_4 @ cycle " & to_string(i));
                check_equal(got => clk_div_6, expected => expected_clk_div_6, msg => "clk_6 @ cycle " & to_string(i));
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

    divide_by_evens_clock_divider_inst : entity work.divide_by_evens_clock_divider
        port map (
            clk => clk,
            rst_n => rst_n,
            clk_div_2 => clk_div_2,
            clk_div_4 => clk_div_4,
            clk_div_6 => clk_div_6
        );
end architecture;
