--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 21
--!  @details    VHDL module for FizzBuzz
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

entity tb_fizzbuzz is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_fizzbuzz is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant FIZZ_CYCLES_EXAMPLE_1: positive := 2;
    constant BUZZ_CYCLES_EXAMPLE_1: positive := 3;
    constant MAX_CYCLES_EXAMPLE_1: positive := 8;
    constant FIZZ_CYCLES: positive := 3;
    constant BUZZ_CYCLES: positive := 5;
    constant MAX_CYCLES: positive := 100;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal fizz_example_1: std_ulogic;
    signal buzz_example_1: std_ulogic;
    signal fizzbuzz_example_1: std_ulogic;
    signal fizz: std_ulogic;
    signal buzz: std_ulogic;
    signal fizzbuzz: std_ulogic;

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
        info("Starting tb_fizzbuzz");

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
        variable expected_fizz_v, expected_buzz_v, expected_fizzbuzz_v: std_ulogic := '0';
        variable expected_counter: natural range 0 to MAX_CYCLES - 1;

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

        procedure reset_expected_values is begin
            expected_counter := expected_counter'subtype'high;
            expected_fizz_v := '1';
            expected_buzz_v := '1';
            expected_fizzbuzz_v := '1';
        end procedure;

        procedure calculate_expected_values is begin
            if rst_n = '0' then
                reset_expected_values;
            else
                expected_counter := expected_counter + 1 when expected_counter < expected_counter'subtype'high else 0;
                expected_fizz_v := '1' when ((expected_counter + 1) mod FIZZ_CYCLES) = 0 else '0';
                expected_buzz_v := '1' when ((expected_counter + 1) mod BUZZ_CYCLES) = 0 else '0';
                expected_fizzbuzz_v := expected_fizz_v and expected_buzz_v;
            end if;
        end procedure;

        procedure test_example_1 is
            -- NOTE: The text-based expected values are wrong, but the waveform is correct
            constant RESET_N_SEQUENCE: std_ulogic_vector := "011111111";
            constant EXPECTED_FIZZ: std_ulogic_vector := "101010101";
            constant EXPECTED_BUZZ: std_ulogic_vector := "100100100";
            constant EXPECTED_FIZZBUZZ: std_ulogic_vector := "100000100";
        begin
            info("1.0) test_example_1");

            reset_expected_values;

            for i in RESET_N_SEQUENCE'low to RESET_N_SEQUENCE'high loop
                rst_n <= RESET_N_SEQUENCE(i);
                wait_clk_cycles(1);
                expected_fizz_v := EXPECTED_FIZZ(i);
                expected_buzz_v := EXPECTED_BUZZ(i);
                expected_fizzbuzz_v := EXPECTED_FIZZBUZZ(i);
                check_equal(got => fizz_example_1, expected => expected_fizz_v, msg => "fizz_example_1 @ cycle " & to_string(i));
                check_equal(got => buzz_example_1, expected => expected_buzz_v, msg => "buzz_example_1 @ cycle " & to_string(i));
                check_equal(got => fizzbuzz_example_1, expected => expected_fizzbuzz_v, msg => "fizzbuzz_example_1 @ cycle " & to_string(i));
            end loop;
        end procedure;

        procedure test_random is begin
            info("2.0) test_random");

            reset_expected_values;
            reset_module;
            start_module;

            for i in 1 to 1000 loop
                -- Randomly glitch reset_n
                rst_n <= random.DistSl(Weight => RESET_N_WEIGHT);
                wait_clk_cycles(1);

                calculate_expected_values;

                check_equal(got => fizz, expected => expected_fizz_v, msg => "fizz @ cycle " & to_string(i));
                check_equal(got => buzz, expected => expected_buzz_v, msg => "buzz @ cycle " & to_string(i));
                check_equal(got => fizzbuzz, expected => expected_fizzbuzz_v, msg => "fizzbuzz @ cycle " & to_string(i));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

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

    DuT_example_1: entity work.fizzbuzz
        generic map (
            FIZZ_CYCLES => FIZZ_CYCLES_EXAMPLE_1,
            BUZZ_CYCLES => BUZZ_CYCLES_EXAMPLE_1,
            MAX_CYCLES => MAX_CYCLES_EXAMPLE_1
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            fizz => fizz_example_1,
            buzz => buzz_example_1,
            fizzbuzz => fizzbuzz_example_1
        );

    DuT: entity work.fizzbuzz
        generic map (
            FIZZ_CYCLES => FIZZ_CYCLES,
            BUZZ_CYCLES => BUZZ_CYCLES,
            MAX_CYCLES => MAX_CYCLES
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            fizz => fizz,
            buzz => buzz,
            fizzbuzz => fizzbuzz
        );
end architecture;
