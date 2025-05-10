--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 14
--!  @details    VHDL module for Stopwatch Timer
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

entity tb_stopwatch_timer is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_stopwatch_timer is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 16;
    constant MAX: positive := 99;
    constant MAX_EXAMPLE_2: positive := 4;

    signal clk: std_ulogic := '0';
    signal reset: std_ulogic := '0';
    signal start_in: std_ulogic := '0';
    signal stop_in: std_ulogic := '0';
    signal count_out: unsigned(DATA_WIDTH - 1 downto 0);
    signal count_out_example_2: unsigned(DATA_WIDTH - 1 downto 0);

    signal start_reg: std_ulogic := '0';
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
        info("Starting tb_stopwatch_timer");

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;
    ------------------------------------------------------------

    start_register: process(clk)
    begin
        if rising_edge(clk) then
            if reset then
                start_reg <= '0';
            elsif stop_in then
                start_reg <= '0';
            elsif start_in or start_reg then
                start_reg <= '1';
            end if;
        end if;
    end process;

    checker: process
        constant PROPAGATION_TIME: time := 1 ns;
        constant RESET_VALUE: count_out'subtype := (others => '0');

        variable random: RandomPType;
        -- To see in the waveform
        variable expected_count: count_out'subtype := (others => '0');

        procedure wait_clk_cycles(n: positive) is begin
            for i in 1 to n loop
                wait until rising_edge(clk);
            end loop;
            wait for PROPAGATION_TIME;
        end procedure;

        -- Works only if the stopwatch timer has been started and not stopped
        function get_expected_count_after_wait(current_count: unsigned; wait_time: natural) return count_out'subtype is
            variable expected_count: current_count'subtype := current_count;
        begin
            expected_count := expected_count + wait_time;

            if expected_count > to_unsigned(MAX, expected_count'length) then
                expected_count := (others => '0');
                expected_count := expected_count + wait_time - 1; -- -1 because the count_out is already incremented by 1
            end if;

            return expected_count;
        end function;

        impure function get_expected_count(current_count: unsigned) return unsigned is begin
            if reset then
                return RESET_VALUE;
            elsif stop_in then
                return current_count;
            elsif start_in or start_reg then
                return get_expected_count_after_wait(current_count => current_count, wait_time => 1);
            end if;

            return current_count;
        end function;

        procedure reset_module is begin
            expected_count := RESET_VALUE;
            reset <= '1';
            start_in <= '0';
            stop_in <= '0';
            wait_clk_cycles(1);
            reset <= '0';
            wait_clk_cycles(1);
        end procedure;

        procedure start_module is begin
            start_in <= '1';
            stop_in <= '0';
        end procedure;

        procedure reset_start_in is begin
            start_in <= '0';
            -- Due to previous wait_clk_cycles, the count_out is already incremented by 1
            expected_count := get_expected_count_after_wait(current_count => expected_count, wait_time => 1);
        end procedure;

        procedure stop_module is begin
            stop_in <= '1';
        end procedure;

        procedure check_reset_value is begin
            check_equal(got => count_out, expected => RESET_VALUE, msg => "Count should be 0 when while reset and 1 clk cycle after.");
        end procedure;

        procedure check_stop(frozen_value: unsigned) is
            variable random_wait_in_clk_cycles: natural := 0;
        begin
            for i in 1 to 10 loop
                random_wait_in_clk_cycles := random.RandInt(1, 10);
                wait_clk_cycles(random_wait_in_clk_cycles);
                check_equal(got => count_out, expected => frozen_value, msg => "Count should not increment when stopped.");
            end loop;
        end procedure;

        procedure test_example_1 is
            constant EXPECTED_VALUES: integer_vector := (0, 1, 2, 3, 3, 3);
            constant START_SEQUENCE: std_ulogic_vector := "100100";
            constant STOP_SEQUENCE: std_ulogic_vector := "000100";
        begin
            info("1.0) test_example_1 - Start pulse, then stop pulse");

            reset_module;

            for i in START_SEQUENCE'range loop
                start_in <= START_SEQUENCE(i);
                stop_in <= STOP_SEQUENCE(i);
                check_equal(got => count_out, expected => EXPECTED_VALUES(i), msg => "Count should increment when started.");
                wait_clk_cycles(1);
            end loop;
        end procedure;

        procedure test_example_2 is
            constant EXPECTED_VALUES: integer_vector := (0, 1, 2, 3, 4, 0, 1);
            constant START_SEQUENCE: std_ulogic_vector := "1010000";
            constant STOP_SEQUENCE: std_ulogic_vector := "0000000";
        begin
            info("2.0) test_example_2 - Wrap around after MAX");

            reset_module;

            for i in START_SEQUENCE'range loop
                start_in <= START_SEQUENCE(i);
                stop_in <= STOP_SEQUENCE(i);
                check_equal(got => count_out_example_2, expected => EXPECTED_VALUES(i), msg => "Count should increment when started.");
                wait_clk_cycles(1);
            end loop;
        end procedure;

        procedure test_example_3 is
            constant EXPECTED_VALUES: integer_vector := (0, 1, 2, 3, 0, 0, 0);
            constant RESET_SEQUENCE: std_ulogic_vector := "0001000";  -- Reset active in cycles 4 and 5
            constant START_SEQUENCE: std_ulogic_vector := "1001000";
            constant STOP_SEQUENCE: std_ulogic_vector := "0001000";
        begin
            info("3.0) test_example_3 - Reset overrides start and stop");

            reset_module;

            for i in START_SEQUENCE'range loop
                reset <= RESET_SEQUENCE(i);
                start_in <= START_SEQUENCE(i);
                stop_in <= STOP_SEQUENCE(i);
                check_equal(got => count_out, expected => EXPECTED_VALUES(i), msg => "Count should increment when started.");
                wait_clk_cycles(1);
            end loop;

            reset <= '0'; -- ensure reset is cleared for future tests
        end procedure;

        procedure test_when_reset is
            variable random_wait_in_clk_cycles: natural := 0;    
        begin
            info("4.0) test_when_reset");

            start_in <= '0';
            reset <= '1';

            for i in 1 to 10 loop
                random_wait_in_clk_cycles := random.RandInt(1, 10);
                wait_clk_cycles(random_wait_in_clk_cycles);
                check_reset_value;
            end loop;
        end procedure;

        procedure test_start_stop is
            constant START_STOP_SEQUENCE: integer := 5;
            constant WAIT_REPETITIONS: integer := 6;

            variable random_wait_in_clk_cycles: natural := 0;
        begin
            info("5.0) test_start_stop");

            reset_module;
            start_module;

            check_reset_value;
            wait_clk_cycles(1);

            reset_start_in;

            for i in 1 to START_STOP_SEQUENCE loop
                for i in 1 to WAIT_REPETITIONS loop
                    random_wait_in_clk_cycles := random.RandInt(1, 10);
                    wait_clk_cycles(random_wait_in_clk_cycles);
                    expected_count := get_expected_count_after_wait(current_count => expected_count, wait_time => random_wait_in_clk_cycles);
                    check_equal(got => count_out, expected => expected_count, msg => "Count should increment when started.");
                end loop;

                stop_module;
                wait_clk_cycles(1);
                stop_in <= '0';

                for i in 1 to WAIT_REPETITIONS loop
                    wait_clk_cycles(1);
                    check_stop(frozen_value => expected_count);
                end loop;

                start_module;
                wait_clk_cycles(1);
                start_in <= '0';
                expected_count := get_expected_count_after_wait(current_count => expected_count, wait_time => 1);
            end loop;
        end procedure;

        procedure test_until_overflow is
            variable random_wait_in_clk_cycles: natural := 0;
        begin
            info("6.0) test_until_overflow");

            reset_module;
            start_module;

            check_reset_value;
            wait_clk_cycles(1);

            reset_start_in;

            -- Check every clock cycle until overflow
            for i in 1 to MAX loop
                wait_clk_cycles(1);
                expected_count := get_expected_count_after_wait(current_count => expected_count, wait_time => 1);
                check_equal(got => count_out, expected => expected_count, msg => "Count should increment when started.");
            end loop;

            -- Check overflow
            expected_count := (others => '0');
            check_equal(got => count_out, expected => expected_count, msg => "Count should overflow to 0.");

            -- Check after overflow
            random_wait_in_clk_cycles := random.RandInt(1, 10);
            wait_clk_cycles(random_wait_in_clk_cycles);
            expected_count := get_expected_count_after_wait(current_count => expected_count, wait_time => random_wait_in_clk_cycles);
            check_equal(got => count_out, expected => expected_count, msg => "Count should overflow to 0.");
        end procedure;

        procedure test_random_overflow is
            constant WAIT_REPETITIONS: integer := 10;
            variable random_wait_in_clk_cycles: natural := 0;
        begin
            info("7.0) test_random_overflow");

            reset_module;
            start_module;

            check_reset_value;
            wait_clk_cycles(1);

            reset_start_in;

            -- Provoke MAX overflow
            for i in 1 to WAIT_REPETITIONS loop
                random_wait_in_clk_cycles := random.RandInt(10, 20);
                wait_clk_cycles(random_wait_in_clk_cycles);
                expected_count := get_expected_count_after_wait(current_count => expected_count, wait_time => random_wait_in_clk_cycles);
                check_equal(got => count_out, expected => expected_count, msg => "Count should increment when started.");
            end loop;

            -- Check after overflow
            random_wait_in_clk_cycles := random.RandInt(1, 10);
            wait_clk_cycles(random_wait_in_clk_cycles);
            expected_count := get_expected_count_after_wait(current_count => expected_count, wait_time => random_wait_in_clk_cycles);
            check_equal(got => count_out, expected => expected_count, msg => "Count should overflow to 0.");
        end procedure;

        procedure test_random_input_values is
            --! 1% of the time reset, 30% of the time stop_in, 50% of the time start_in
            constant STOP_WEIGHT_SEQUENCE: NaturalVSlType(std_ulogic'('0') to '1') := ('0' => 70, '1' => 30);
            constant START_WEIGHT_SEQUENCE: NaturalVSlType(std_ulogic'('0') to '1') := ('0' => 50, '1' => 50);

            variable random_wait_in_clk_cycles: natural := 0;
        begin
            info("8.0) test_random_input_values");

            reset_module;
            start_module;

            check_reset_value;
            wait_clk_cycles(1);

            reset_start_in;

            for i in 1 to 1000 loop
                reset <= random.DistSl(Weight => RESET_WEIGHT);
                start_in <= random.DistSl(Weight => START_WEIGHT_SEQUENCE);
                stop_in <= random.DistSl(Weight => STOP_WEIGHT_SEQUENCE);
    
                random_wait_in_clk_cycles := random.RandInt(1, 10);

                for i in 1 to random_wait_in_clk_cycles loop
                    wait_clk_cycles(1);
                    expected_count := get_expected_count(current_count => expected_count);
                end loop;

                check_equal(got => count_out, expected => expected_count, msg => "expected_count");
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);
        
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_example_2") then
                test_example_2;
            elsif run("test_example_3") then
                test_example_3;
            elsif run("test_when_reset") then
                test_when_reset;
            elsif run("test_start_stop") then
                test_start_stop;
            elsif run("test_until_overflow") then
                test_until_overflow;
            elsif run("test_random_overflow") then
                test_random_overflow;
            elsif run("test_random_input_values") then
                test_random_input_values;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    DuT: entity work.stopwatch_timer
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            MAX => MAX
        )
        port map (
            clk => clk,
            reset => reset,
            start_in => start_in,
            stop_in => stop_in,
            count_out => count_out
        );

    Dut_example_2: entity work.stopwatch_timer
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            MAX => MAX_EXAMPLE_2
        )
        port map (
            clk => clk,
            reset => reset,
            start_in => start_in,
            stop_in => stop_in,
            count_out => count_out_example_2
        );
end architecture;
