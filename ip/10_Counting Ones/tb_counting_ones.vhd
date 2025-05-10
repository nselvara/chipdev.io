--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 10
--!  @details    VHDL module for Counting Ones
--! ----------------------------------------------------------------------------

-- vunit: run_all_in_same_sim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.RandomPType;

use work.util_pkg.all;
use work.tb_utils.all;

entity tb_counting_ones is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_counting_ones is
    constant SIM_TIMEOUT: time := 1 ms;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 32;

    signal din: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal dout: unsigned(to_bits(DATA_WIDTH) - 1 downto 0);
    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_counting_ones");

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
        -- To see in the waveform
        variable expected_count: unsigned(dout'range);

        procedure test_example_1 is
            constant TEST_INPUTS: integer_vector := (16#0B#, 16#00#); -- 0b1011 and 0b0000
            constant EXPECTED_ONES: integer_vector := (3, 0);          -- 3 ones in 1011, 0 ones in 0000
        begin
            info("1.0) test_example_1 - Count number of 1s in input vector");

            for i in TEST_INPUTS'range loop
                din <= to_unsigned(TEST_INPUTS(i), din'length);
                wait for PROPAGATION_TIME;
                check_equal(got => dout, expected => to_unsigned(EXPECTED_ONES(i), dout'length), msg => "dout(" & to_string(i) & ")");
            end loop;
        end procedure;

        procedure test_all_zeroes is begin
            info("2.0) test_all_zeroes");

            din <= (others => '0');
            wait for PROPAGATION_TIME;
            expected_count := to_unsigned(0, dout'length);
            check_equal(got => dout, expected => expected_count, msg => "Test case 1 failed: All zeros");
        end procedure;

        procedure test_all_ones is begin
            info("3.0) test_all_ones");

            din <= (others => '1');
            wait for PROPAGATION_TIME;
            expected_count := to_unsigned(din'length, dout'length);
            check_equal(got => dout, expected => expected_count, msg => "Test case 2 failed: All ones");

        end procedure;

        procedure test_random_values is begin
            info("4.0) test_random_values");
    
            for i in 1 to 1000 loop
                din <= random.RandUnsigned(Size => din'length);
                wait for PROPAGATION_TIME;
                expected_count := din'high - get_amount_of_state(data => std_ulogic_vector(din), state => '0') + 1;
                check_equal(got => dout, expected => expected_count, msg => "Test case 3 failed: Random value " & to_bstring(din));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_all_zeroes") then
                test_all_zeroes;
            elsif run("test_all_ones") then
                test_all_ones;
            elsif run("test_random_values") then
                test_random_values;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    counting_ones_inst: entity work.counting_ones
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            din => din,
            dout => dout
        );
end architecture;
