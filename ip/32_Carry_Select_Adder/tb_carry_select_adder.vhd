--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 32
--!  @details    VHDL module for Carry Select Adder
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

entity tb_carry_select_adder is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_carry_select_adder is
    constant SIM_TIMEOUT: time := 1 ms;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 24;
    -- constant DATA_WIDTH: positive := 25;
    constant STAGES: positive := 4;

    signal a: unsigned(DATA_WIDTH - 1 downto 0);
    signal b: unsigned(DATA_WIDTH - 1 downto 0);
    signal sum: unsigned(DATA_WIDTH downto 0);

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_carry_select_adder");

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

        procedure print_debug_info(a, b, sum, expected_sum: unsigned) is begin
            debug("a = " & to_integer_string(a) & " (0x" & to_hstring(a) & "), " & to_nibble_string(a));
            debug("b = " & to_integer_string(b) & " (0x" & to_hstring(b) & "), " & to_nibble_string(b));
            debug("sum = "  & to_integer_string(sum) & " (0x" & to_hstring(sum) & "), " & to_nibble_string(sum));
            debug("expected_sum = " & to_integer_string(expected_sum) & " (0x" & to_hstring(expected_sum) & "), " & to_nibble_string(expected_sum));
        end procedure;

        impure function return_error_msg(cycle: natural; a, b: unsigned) return string is begin
            return
                "sum @ cycle " & to_string(cycle) & ":" & LF &
                "  a = " & to_integer_string(a) & " (0x" & to_hstring(a) & ", " & to_nibble_string(a) & ")" & LF &
                "  b = " & to_integer_string(b) & " (0x" & to_hstring(b) & ", " & to_nibble_string(b) & ")" & LF
            ;
        end function;

        procedure test_example_1 is
            type unsigned_vector is array (natural range <>) of unsigned;

            constant A_SEQUENCE: unsigned_vector(open)(a'range) := (
                0 => resize(x"3fc", a'length),
                1 => resize(x"0de", a'length),
                2 => resize(x"14d", a'length),
                3 => resize(x"00c", a'length),
                4 => resize(x"05b", a'length)
            );
            constant B_SEQUENCE: unsigned_vector(open)(b'range) := (
                0 => resize(x"028", b'length),
                1 => resize(x"004", b'length),
                2 => resize(x"003", b'length),
                3 => resize(x"3e7", b'length),
                4 => resize(x"000", b'length)
            );
            constant EXPECTED_SUM_SEQUENCE: unsigned_vector(open)(sum'range) := (
                0 => resize(x"424", sum'length),
                1 => resize(x"0e2", sum'length),
                2 => resize(x"150", sum'length),
                3 => resize(x"3f3", sum'length),
                4 => resize(x"05b", sum'length)
            );

            variable expected_sum: sum'subtype;
        begin
            info("1.0) test_example_1" & LF);

            for i in A_SEQUENCE'low to A_SEQUENCE'high loop
                info("1." & to_string(i + 1) & ") example " & to_string(i + 1));
                a <= A_SEQUENCE(i);
                b <= B_SEQUENCE(i);

                wait for PROPAGATION_TIME;

                expected_sum := EXPECTED_SUM_SEQUENCE(i);
                print_debug_info(a, b, sum, expected_sum);
                check_equal(
                    got => sum,
                    expected => expected_sum,
                    msg => return_error_msg(cycle => i, a => a, b => b)
                );
            end loop;

            info("1.0) test_example_1 passed!" & LF);
        end procedure;

        procedure test_random is
            constant REPETITION_AMOUNT: natural := 1000;
            variable a_v, b_v: unsigned(DATA_WIDTH - 1 downto 0);
            variable expected_sum: sum'subtype;
        begin
            info(
                "2.0) test_random" & LF &
                "Testing with random values " & to_string(REPETITION_AMOUNT) & " times." & LF
            );

            for i in 1 to REPETITION_AMOUNT loop
                a_v := random.RandUnsigned(Size => a'length);
                b_v := random.RandUnsigned(Size => b'length);
                a <= a_v;
                b <= b_v;

                wait for PROPAGATION_TIME;

                expected_sum := resize(a_v, sum'length) + resize(b_v, sum'length);
                print_debug_info(a, b, sum, expected_sum);
                check_equal(
                    got => sum,
                    expected => expected_sum,
                    msg => return_error_msg(cycle => i, a => a, b => b)
                );
            end loop;

            info("2.0) test_random passed!" & LF);
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait for PROPAGATION_TIME;

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

    carry_select_adder_inst: entity work.carry_select_adder
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            STAGES => STAGES
        )
        port map (
            a => a,
            b => b,
            cin => '0',
            sum => sum
        );
end architecture;
