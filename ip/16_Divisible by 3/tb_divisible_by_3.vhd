--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question
--!  @details    VHDL module for Divisible by 3
--! ----------------------------------------------------------------------------

-- vunit: run_all_in_same_sim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.RandomPType;
use osvvm.MessagePkg.MessagePType;

use work.tb_utils.all;
use work.util_pkg.all;

entity tb_divisible_by_3 is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_divisible_by_3 is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din : std_ulogic := '0';
    signal dout : std_ulogic;

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
        info("Starting tb_divisible_by_3");

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
        -- To see in the waveform
        variable expected_dout: std_ulogic;
        -- 0, 1, 2 are the possible remainders for modulo 3
        variable remainder_counter: natural range 0 to 2 := 0;
        variable bit_idx: natural := 0;

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

        impure function get_expected_dout return std_ulogic is begin
            if rst_n = '0' then
                remainder_counter := 0;
                bit_idx := 0;
                return '0';
            else
                -- If it overflows, just wrap around
                -- *2 is the same as << 1
                remainder_counter := (remainder_counter * 2) mod 3;
                    
                if din then
                    if remainder_counter < remainder_counter'subtype'high then
                        remainder_counter := remainder_counter + 1;
                    else
                        remainder_counter := 0;
                    end if;
                end if;

                bit_idx := bit_idx + 1;
                if (bit_idx > 0) and (remainder_counter mod 3 = 0) then
                    return '1';
                else
                    return '0';
                end if;
            end if;

            return '0';
        end function;

        procedure test_example_1 is
            constant RESET_N_SEQUENCE: std_ulogic_vector := "11110111";
            constant DIN_SEQUENCE: std_ulogic_vector := "10011111";
            constant EXPECTED_OUTPUT_SEQUENCE: std_ulogic_vector := "00010010";
        begin
            info("1.0) test_example_1 - Overlapping sequence detection");
            
            reset_module;

            for i in DIN_SEQUENCE'low to DIN_SEQUENCE'high loop
                rst_n <= RESET_N_SEQUENCE(i);
                din <= DIN_SEQUENCE(i);
                wait_clk_cycles(1);
                expected_dout := EXPECTED_OUTPUT_SEQUENCE(i);
                check_equal(got => dout, expected => expected_dout, msg => "dout for given din " & to_string(din) & " at index " & to_string(i));
            end loop;
        end procedure;

        procedure test_all_zeroes is begin
            info("2.0) test_all_zeroes");

            reset_module;

            rst_n <= '1';
            expected_dout := '1';

            for i in 1 to 100 loop
                din <= '0';
                wait_clk_cycles(1);
                check_equal(got => dout, expected => expected_dout, msg => "Test case all zeros");
            end loop;
        end procedure;

        procedure test_all_ones is begin
            info("3.0) test_all_ones");

            reset_module;

            rst_n <= '1';
            remainder_counter := 0;
            bit_idx := 0;

            for i in 1 to 100 loop
                din <= '1';
                wait_clk_cycles(1);
                expected_dout := get_expected_dout;
                check_equal(got => dout, expected => expected_dout, msg => "Test case all ones");
            end loop;
        end procedure;

        -- Testing with length involves huge number of iterations
        -- and is not practical for simulation.
        procedure test_constrained_known_combinations is
            constant MAX_ITERATIONS: natural := 1000;
            variable din_value: unsigned(to_bits(MAX_ITERATIONS) - 1 downto 0);
        begin
            info("4.0) test_constrained_known_combinations");

            for i in 0 to MAX_ITERATIONS - 1 loop
                remainder_counter := 0;
                bit_idx := 0;
                reset_module;
                rst_n <= '1';
                din_value := to_unsigned(i, din_value'length);

                for j in din_value'low to din_value'high loop
                    din <= din_value(j);
                    wait_clk_cycles(1);
                    expected_dout := get_expected_dout;
                    check_equal(got => dout, expected => expected_dout, msg => "Test case constrained known combinations");
                end loop;
            end loop;
        end procedure;

        procedure test_random_values is begin
            info("5.0) test_random_values");

            reset_module;
            remainder_counter := 0;
            bit_idx := 0;

            for i in 1 to 1000 loop
                rst_n <= random.DistSl(weight => RESET_N_WEIGHT);
                din <= To_01(random.RandSl); -- To weed out other than 0, 1
                wait_clk_cycles(1);
                expected_dout := get_expected_dout;
                check_equal(got => dout, expected => expected_dout, msg => "Test case random values");
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_all_zeroes") then
                test_all_zeroes;
            elsif run("test_all_ones") then
                test_all_ones;
            elsif run("test_constrained_known_combinations") then
                test_constrained_known_combinations;
            elsif run("test_random_values") then
                test_random_values;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    divisible_by_3_inst : entity work.divisible_by_3
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            dout => dout
        );
end architecture;
