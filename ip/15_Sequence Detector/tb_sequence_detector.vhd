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

    signal clk: std_ulogic := '1';
    signal rst_n: std_ulogic := '1';
    signal din: std_ulogic := '0';
    signal dout: std_ulogic;

    -- See the DuT for the reverse range
    signal din_sequence: std_ulogic_vector(SEQUENCE_PATTERN'reverse_range) := (others => '0');
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

    din_sequence_proc: process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                din_sequence <= (others => '0');
            elsif din_sequence'ascending then
                din_sequence <= din & din_sequence(0 to din_sequence'high - 1);
            else
                din_sequence <= din_sequence(din_sequence'high - 1 downto 0) & din;
            end if;
        end if;
    end process;

    checker: process
        constant PROPAGATION_TIME: time := 1 ns;
        variable random: RandomPType;
        variable expected_dout: std_ulogic := '0';

        procedure wait_clk_cycles(n: positive) is begin
            for i in 1 to n loop
                wait until rising_edge(clk);
            end loop;
            wait for PROPAGATION_TIME;
        end procedure;

        procedure reset_module is begin
            rst_n <= '0';
            wait_clk_cycles(1);
            rst_n <= '1';
            wait_clk_cycles(1);
        end procedure;

        impure function get_expected_sequence return boolean is begin
            return (din_sequence = SEQUENCE_PATTERN);
        end function;

        procedure test_example_1 is
            constant RESET_N_SEQUENCE: std_ulogic_vector := "01111111111111";
            constant DIN_SEQUENCE: std_ulogic_vector := "10001010101111";
            constant EXPECTED_OUTPUT_SEQUENCE: std_ulogic_vector := "00000001010000"; -- pulses at 4 and 6
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

        procedure test_example_2 is
            constant RESET_N_SEQUENCE: std_ulogic_vector := "0000111111";
            constant DIN_SEQUENCE: std_ulogic_vector := "1010101011";
            constant EXPECTED_OUTPUT_SEQUENCE: std_ulogic_vector := "0000000100";
        begin
            info("2.0) test_example_2 - Reset blocks first detection");
            
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
            info("3.0) test_all_zeroes");

            reset_module;

            expected_dout := '0';
            for i in 1 to 100 loop
                din <= '0';
                wait_clk_cycles(1);
                check_equal(got => dout, expected => expected_dout, msg => "Test case all zeros");
            end loop;
        end procedure;

        procedure test_all_ones is begin
            info("4.0) test_all_ones");

            reset_module;

            expected_dout := '0';
            for i in 1 to 100 loop
                din <= '1';
                wait_clk_cycles(1);
                check_equal(got => dout, expected => expected_dout, msg => "Test case all ones");
            end loop;
        end procedure;

        procedure test_random_values is begin
            info("5.0) test_random_values");

            for i in 1 to 1000 loop
                din <= random.DistSl(weight => WEIGHT_50_PERCENT);
                wait_clk_cycles(1);
                expected_dout := '1' when get_expected_sequence else '0';
                wait for PROPAGATION_TIME;
                check_equal(got => dout, expected => expected_dout, msg => "Failed for random din sequence " & to_bstring(din_sequence));
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
