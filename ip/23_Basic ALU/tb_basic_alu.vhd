--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question
--!  @details    VHDL module for Basic ALU
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

entity tb_basic_alu is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_basic_alu is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 4;
    signal a: unsigned(DATA_WIDTH - 1 downto 0);
    signal b: unsigned(DATA_WIDTH - 1 downto 0);
    signal a_plus_b: unsigned(DATA_WIDTH - 1 downto 0);
    signal a_minus_b: unsigned(DATA_WIDTH - 1 downto 0);
    signal not_a: unsigned(DATA_WIDTH - 1 downto 0);
    signal a_and_b: unsigned(DATA_WIDTH - 1 downto 0);
    signal a_or_b: unsigned(DATA_WIDTH - 1 downto 0);
    signal a_xor_b: unsigned(DATA_WIDTH - 1 downto 0);

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------                                               
    -- VUnit
    ------------------------------------------------------------                                        
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_basic_alu");

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
        variable expected_a_plus_b: unsigned(DATA_WIDTH - 1 downto 0);
        variable expected_a_minus_b: unsigned(DATA_WIDTH - 1 downto 0);
        variable expected_not_a: unsigned(DATA_WIDTH - 1 downto 0);
        variable expected_a_and_b: unsigned(DATA_WIDTH - 1 downto 0);
        variable expected_a_or_b: unsigned(DATA_WIDTH - 1 downto 0);
        variable expected_a_xor_b: unsigned(DATA_WIDTH - 1 downto 0);

        procedure check_outputs is begin
            log("a = " & to_string(a));
            log("b = " & to_string(b));
            check_equal(got => a_plus_b, expected => expected_a_plus_b, msg => "a_plus_b");
            check_equal(got => a_minus_b, expected => expected_a_minus_b, msg => "a_minus_b");
            check_equal(got => not_a, expected => expected_not_a, msg => "not_a");
            check_equal(got => a_and_b, expected => expected_a_and_b, msg => "a_and_b");
            check_equal(got => a_or_b, expected => expected_a_or_b, msg => "a_or_b");
            check_equal(got => a_xor_b, expected => expected_a_xor_b, msg => "a_xor_b");
        end procedure;

        procedure test_examples is
            type unsigned_vector is array (natural range <>) of unsigned(DATA_WIDTH - 1 downto 0);

            constant A_SEQUENCE: unsigned_vector := (
                0 => "0001", 
                1 => "1111",
                2 => "0001"
            );
            constant B_SEQUENCE: unsigned_vector := (
                0 => "0000",
                1 => "0001",
                2 => "1111"
            );
            constant EXPECTED_A_PLUS_B_SEQUENCE: unsigned_vector := (
                0 => "0001",
                1 => "0000",
                2 => "0000"
            );
            constant EXPECTED_A_MINUS_B_SEQUENCE: unsigned_vector := (
                0 => "0001",
                1 => "1110",
                2 => "0010"
            );
            constant EXPECTED_NOT_A_SEQUENCE: unsigned_vector := (
                0 => "1110",
                1 => "0000",
                2 => "1110"
            );
            constant EXPECTED_A_AND_B_SEQUENCE: unsigned_vector := (
                0 => "0000",
                1 => "0001",
                2 => "0001"
            );
            constant EXPECTED_A_OR_B_SEQUENCE: unsigned_vector := (
                0 => "0001",
                1 => "1111",
                2 => "1111"
            );
            constant EXPECTED_A_XOR_B_SEQUENCE: unsigned_vector := (
                0 => "0001",
                1 => "1110",
                2 => "1110"
            );
        begin
            info("1.0) test_examples (1, 2 and 3)");

            for i in A_SEQUENCE'low to A_SEQUENCE'high loop
                info("1.1) example " & to_string(i + 1));
                a <= A_SEQUENCE(i);
                b <= B_SEQUENCE(i);

                wait for PROPAGATION_TIME;

                expected_a_plus_b := EXPECTED_A_PLUS_B_SEQUENCE(i);
                expected_a_minus_b := EXPECTED_A_MINUS_B_SEQUENCE(i);
                expected_not_a := EXPECTED_NOT_A_SEQUENCE(i);
                expected_a_and_b := EXPECTED_A_AND_B_SEQUENCE(i);
                expected_a_or_b := EXPECTED_A_OR_B_SEQUENCE(i);
                expected_a_xor_b := EXPECTED_A_XOR_B_SEQUENCE(i);
    
                check_outputs;
            end loop;
        end procedure;

        procedure test_random is
            variable e, d, c: bit;
            variable a_v, b_v: unsigned(DATA_WIDTH - 1 downto 0);
            variable expected_a_plus_b_v, expected_a_minus_b_v: unsigned(DATA_WIDTH - 1 downto 0);
            variable expected_not_a_v, expected_a_and_b_v, expected_a_or_b_v, expected_a_xor_b_v: unsigned(DATA_WIDTH - 1 downto 0);
        begin
            info("2.0) test_random");

            for i in 1 to 1000 loop
                a_v := random.RandUnsigned(Size => a'length);
                b_v := random.RandUnsigned(Size => b'length);

                a <= a_v;
                b <= b_v;

                wait for PROPAGATION_TIME;

                expected_a_plus_b_v := resize(a_v + b_v, expected_a_plus_b_v'length);
                expected_a_minus_b_v := resize(a_v - b_v, expected_a_minus_b_v'length);
                expected_not_a_v := not a_v;
                expected_a_and_b_v := a_v and b_v;
                expected_a_or_b_v := a_v or b_v;
                expected_a_xor_b_v := a_v xor b_v;

                check_equal(got => a_plus_b, expected => expected_a_plus_b_v, msg => "a_plus_b @ cycle " & to_string(i));
                check_equal(got => a_minus_b, expected => expected_a_minus_b_v, msg => "a_minus_b @ cycle " & to_string(i));
                check_equal(got => not_a, expected => expected_not_a_v, msg => "not_a @ cycle " & to_string(i));
                check_equal(got => a_and_b, expected => expected_a_and_b_v, msg => "a_and_b @ cycle " & to_string(i));
                check_equal(got => a_or_b, expected => expected_a_or_b_v, msg => "a_or_b @ cycle " & to_string(i));
                check_equal(got => a_xor_b, expected => expected_a_xor_b_v, msg => "a_xor_b @ cycle " & to_string(i));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this line as VUnit will assert error.
        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_examples") then
                test_examples;
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    basic_alu_inst : entity work.basic_alu
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            a => a,
            b => b,
            a_plus_b => a_plus_b,
            a_minus_b => a_minus_b,
            not_a => not_a,
            a_and_b => a_and_b,
            a_or_b => a_or_b,
            a_xor_b => a_xor_b
        );
end architecture;
