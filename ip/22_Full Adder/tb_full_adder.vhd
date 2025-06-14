--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 22
--!  @details    VHDL module for Full Adder
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

entity tb_full_adder is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_full_adder is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    signal a: std_ulogic;
    signal b: std_ulogic;
    signal cin: std_ulogic;

    signal sum_operators: std_ulogic;
    signal cout_operators: std_ulogic;
    signal sum_gate: std_ulogic;
    signal cout_gate: std_ulogic;

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------                                               
    -- VUnit
    ------------------------------------------------------------                                        
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_full_adder");

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
        variable expected_sum: std_ulogic;
        variable expected_cout: std_ulogic;

        procedure test_example_1 is
            constant A_SEQUENCE: std_ulogic_vector := "000001111111111";
            constant B_SEQUENCE: std_ulogic_vector := "000001111111111";
            constant CIN_SEQUENCE: std_ulogic_vector := "000000000011111";
            constant EXPECTED_COUT_SEQUENCE: std_ulogic_vector := "000001111111111";
            constant EXPECTED_SUM_SEQUENCE: std_ulogic_vector := "000000000011111";
        begin
            info("1.0) test_example_1");

            for i in A_SEQUENCE'low to A_SEQUENCE'high loop
                a <= A_SEQUENCE(i);
                b <= B_SEQUENCE(i);
                cin <= CIN_SEQUENCE(i);

                wait for PROPAGATION_TIME;

                expected_sum := EXPECTED_SUM_SEQUENCE(i);
                expected_cout := EXPECTED_COUT_SEQUENCE(i);
                check_equal(got => sum_operators, expected => expected_sum, msg => "sum_operators @ cycle " & to_string(i));
                check_equal(got => cout_operators, expected => expected_cout, msg => "cout_operators @ cycle " & to_string(i));
                check_equal(got => sum_gate, expected => expected_sum, msg => "sum_gate @ cycle " & to_string(i));
                check_equal(got => cout_gate, expected => expected_cout, msg => "cout_gate @ cycle " & to_string(i));
            end loop;
        end procedure;

        procedure test_random is
            variable a_v, b_v, cin_v: unsigned(0 downto 0);
            variable expected_sum_v, expected_cout_v: std_ulogic;
        begin
            info("2.0) test_random");

            for i in 1 to 1000 loop
                a_v := random.RandUnsigned(Size => a_v'length);
                b_v := random.RandUnsigned(Size => b_v'length);
                cin_v := random.RandUnsigned(Size => cin_v'length);

                a <= a_v(0);
                b <= b_v(0);
                cin <= cin_v(0);

                wait for PROPAGATION_TIME;

                (expected_cout_v, expected_sum_v) := ('0' & a_v) + ('0' & b_v) + ('0' & cin_v);

                check_equal(got => sum_operators, expected => expected_sum_v, msg => "sum_operators @ cycle " & to_string(i));
                check_equal(got => cout_operators, expected => expected_cout_v, msg => "cout_operators @ cycle " & to_string(i));
                check_equal(got => sum_gate, expected => expected_sum_v, msg => "sum_gate @ cycle " & to_string(i));
                check_equal(got => cout_gate, expected => expected_cout_v, msg => "cout_gate @ cycle " & to_string(i));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this line as VUnit will assert error.
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

    DuT_operators_implementation: entity work.full_adder(behavioural_operators_implementation)
        port map (
            a => a,
            b => b,
            cin => cin,
            sum => sum_operators,
            cout => cout_operators
        );

    DuT_behavioural_gate_implementation: entity work.full_adder(behavioural_gate_implementation)
        port map (
            a => a,
            b => b,
            cin => cin,
            sum => sum_gate,
            cout => cout_gate
        );
end architecture;
