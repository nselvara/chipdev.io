--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 15
--!  @details    VHDL module for Sequence Detector
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

entity tb_sequence_detector is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_sequence_detector is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant SEQUENCE_PATTERN: std_ulogic_vector := "1010";

    signal clk: std_ulogic;
    signal rst_n: std_ulogic;
    signal din: std_ulogic;
    signal dout: std_ulogic;

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
        info("Starting tb_sequence_detector");

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
            constant TEST_LENGTH: natural := 6;
            -- Sequence: 1,0,1,0,1,0 ? should detect at clk=4 and clk=6 (overlapping)
            constant TEST_INPUT: std_ulogic_vector(TEST_LENGTH - 1 downto 0) := "101010";
            constant expected_output: TEST_INPUT'subtype := "000101"; -- pulses at 4 and 6
        begin
            info("1.0) test_example_1 - Overlapping sequence detection");

            reset_module;
            start_module;

            for i in TEST_INPUT'low to TEST_INPUT'high loop
                din <= TEST_INPUT(i);
                wait_clk_cycles(1);
                check_equal(got => dout, expected => expected_output(i), msg => "dout at index " & to_string(i));
            end loop;
        end procedure;

        procedure test_example_2 is
            constant TEST_LENGTH: natural := 8;
            -- Sequence: 1,0,1,0 with reset during detection ? no pulse expected
            --           1,0,1,0 ? detection should occur on second sequence
            constant TEST_INPUT: std_ulogic_vector(TEST_LENGTH - 1 downto 0) := "10101010";
            constant expected_output: TEST_INPUT'subtype := "00000001";
        begin
            info("2.0) test_example_2 - Reset blocks first detection");

            reset_module;
            start_module;

            for i in 0 to 3 loop
                din <= TEST_INPUT(i);
                wait_clk_cycles(1);
            end loop;

            reset_module; -- Reset after 4 bits
            start_module;

            for i in 4 to 7 loop
                din <= TEST_INPUT(i);
                wait_clk_cycles(1);
                check_equal(got => dout, expected => expected_output(i), msg => "dout at index " & to_string(i));
            end loop;
        end procedure;

        procedure test_example_3 is
            -- Sequence without `1010`, ensure no false positive
            constant TEST_LENGTH: natural := 9;
            constant TEST_INPUT: std_ulogic_vector(TEST_LENGTH - 1 downto 0) := "111000111";
            constant expected_output: TEST_INPUT'subtype := (TEST_INPUT'range => '0');
        begin
            info("3.0) test_example_3 - No detection when sequence doesn't appear");

            reset_module;
            start_module;

            for i in TEST_INPUT'low to TEST_INPUT'high loop
                din <= TEST_INPUT(i);
                wait_clk_cycles(1);
                check_equal(got => dout, expected => expected_output(i), msg => "dout at index " & to_string(i));
            end loop;
        end procedure;

        procedure test_all_zeroes is begin
            info("4.0) test_all_zeroes");

            din <= '0';
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0', msg => "Test case all zeros");
        end procedure;

        procedure test_all_ones is begin
            info("5.0) test_all_ones");

            din <= '1';
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0', msg => "Test case all ones");
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
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    sequence_detector_inst : entity work.sequence_detector
        generic map (
            SEQUENCE_PATTERN => SEQUENCE_PATTERN
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            dout => dout
        );
end architecture;
