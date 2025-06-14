--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 24
--!  @details    VHDL module for Ripple Carry Adder
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

entity tb_ripple_carry_adder is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_ripple_carry_adder is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 8;
    signal a: unsigned(DATA_WIDTH - 1 downto 0);
    signal b: unsigned(DATA_WIDTH - 1 downto 0);
    signal sum: unsigned(DATA_WIDTH downto 0);
    signal cout_int: unsigned(DATA_WIDTH - 1 downto 0);

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------                                               
    -- VUnit
    ------------------------------------------------------------                                        
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_ripple_carry_adder");

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
        variable expected_sum: sum'subtype;
        variable expected_cout_int: cout_int'subtype;

        procedure check_outputs(cycle: natural) is begin
            debug("a = " & to_string(a));
            debug("b = " & to_string(b));
            check_equal(got => sum, expected => expected_sum, msg => "sum @ cycle " & to_string(cycle));
            check_equal(got => cout_int, expected => expected_cout_int, msg => "cout_int @ cycle " & to_string(cycle));
        end procedure;

        procedure test_example_1 is
            type unsigned_vector is array (natural range <>) of unsigned;

            -- NOTE: `open` is used to skip the range check, as the range is determined by the number of elements in the array.
            constant A_SEQUENCE: unsigned_vector(open)(a'range) := (
                0 => "00001110",
                1 => "10000000",
                2 => "11111111",
                3 => (others => '0'),
                4 => "11001000"
            );
            constant B_SEQUENCE: unsigned_vector(open)(b'range) := (
                0 => "10001001",
                1 => "10000000",
                2 => "11111111",
                3 => "01100100",
                4 => "11001010"
            );
            constant EXPECTED_SUM_SEQUENCE: unsigned_vector(open)(sum'range) := (
                0 => "010010111",
                1 => "100000000",
                2 => "111111110",
                3 => "001100100",
                4 => "110010010"
            );
            constant EXPECTED_COUT_INT_SEQUENCE: unsigned_vector(open)(cout_int'range) := (
                0 => "00001000",
                1 => "10000000",
                2 => "11111111",
                3 => "00000000",
                4 => "11001000"
            );
        begin
            info("1.0) test_example_1");

            for i in A_SEQUENCE'low to A_SEQUENCE'high loop
                info("1.1) example " & to_string(i + 1));
                a <= A_SEQUENCE(i);
                b <= B_SEQUENCE(i);

                wait for PROPAGATION_TIME;

                expected_sum := EXPECTED_SUM_SEQUENCE(i);
                expected_cout_int := EXPECTED_COUT_INT_SEQUENCE(i);
    
                check_outputs(cycle => i);
            end loop;
        end procedure;

        procedure test_random is
            variable a_v, b_v: unsigned(DATA_WIDTH - 1 downto 0);
            variable tmp: unsigned(1 downto 0);
        begin
            info("2.0) test_random");

            for iter in 1 to 1000 loop  -- Changed variable name to avoid collision
                a_v := random.RandUnsigned(Size => a'length);
                b_v := random.RandUnsigned(Size => b'length);
                a <= a_v;
                b <= b_v;
                wait for PROPAGATION_TIME;

                expected_cout_int := (others => '0');
                expected_sum := (others => '0');

                -- Calculate bit by bit
                for i in 0 to DATA_WIDTH - 1 loop
                    tmp := ("0" & a_v(i)) + b_v(i);
                    if i /= 0 then
                        tmp := tmp + expected_cout_int(i - 1);
                    end if;
                    expected_cout_int(i) := tmp(1);
                    expected_sum(i) := tmp(0);
                end loop;

                -- Set the MSB of the sum
                expected_sum(DATA_WIDTH) := expected_cout_int(DATA_WIDTH - 1);
                check_outputs(cycle => iter);
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

    ripple_carry_adder_inst: entity work.ripple_carry_adder
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            a => a,
            b => b,
            sum => sum,
            cout_int => cout_int
        );
end architecture;
