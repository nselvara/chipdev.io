--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question
--!  @details    VHDL module for Palindrome Detector
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

entity tb_palindrome_detector is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_palindrome_detector is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 16;
    constant DATA_WIDTH_EXAMPLE: positive := 4;

    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal din_example_1: std_ulogic_vector(DATA_WIDTH_EXAMPLE - 1 downto 0);
    signal dout: std_ulogic;
    signal dout_example_1: std_ulogic;

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------                                               
    -- VUnit
    ------------------------------------------------------------                                        
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_palindrome_detector");

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
        variable expected_dout: std_ulogic;

        impure function get_expected_sequence return boolean is
            variable dout_reversed: din'subtype;
        begin
            for i in din'low to din'high loop
                dout_reversed(i) := din(din'high - i);
            end loop;
            return (din = dout_reversed);
        end function;

        procedure test_example_1 is
            constant DIN_SEQUENCE: integer_vector := (16#9#, 16#5#);
            constant EXPECTED_OUTPUT_SEQUENCE: std_ulogic_vector := "10";    
        begin
            info("1.0) test_example_1");

            for i in DIN_SEQUENCE'low to DIN_SEQUENCE'high loop
                din_example_1 <= std_ulogic_vector(to_unsigned(DIN_SEQUENCE(i), din_example_1'length));
                wait for PROPAGATION_TIME;
                expected_dout := EXPECTED_OUTPUT_SEQUENCE(i);
                check_equal(got => dout_example_1, expected => expected_dout, msg => "dout_example_1 for given din_example_1 " & to_string(din_example_1) & " at index " & to_string(i));
            end loop;
        end procedure;

        procedure test_all_zeroes is begin
            info("2.0) test_all_zeroes");

            expected_dout := '1';
            for i in 1 to 100 loop
                din <= (others => '0');
                wait for PROPAGATION_TIME;
                check_equal(got => dout, expected => expected_dout, msg => "Test case all zeros");
            end loop;
        end procedure;

        procedure test_all_ones is begin
            info("3.0) test_all_ones");

            expected_dout := '1';
            for i in 1 to 100 loop
                din <= (others => '1');
                wait for PROPAGATION_TIME;
                check_equal(got => dout, expected => expected_dout, msg => "Test case all ones");
            end loop;
        end procedure;

        procedure test_random_values is begin
            info("4.0) test_random_values");

            for i in 1 to 1000 loop
                din <= random.RandSlv(Size => din'length);
                wait for PROPAGATION_TIME;
                expected_dout := '1' when get_expected_sequence else '0';
                wait for PROPAGATION_TIME;
                check_equal(got => dout, expected => expected_dout, msg => "Failed for random din " & to_bstring(din));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this line as VUnit will assert error.
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

    DuT: entity work.palindrome_detector
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            din => din,
            dout => dout
        );

    DuT_example_1: entity work.palindrome_detector
        generic map (
            DATA_WIDTH => DATA_WIDTH_EXAMPLE
        )
        port map (
            din => din_example_1,
            dout => dout_example_1
        );
end architecture;
