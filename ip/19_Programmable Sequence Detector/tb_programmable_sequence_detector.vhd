--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 18
--!  @details    VHDL module for Programmable Sequence Detector
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

entity tb_programmable_sequence_detector is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_programmable_sequence_detector is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: integer := 5;

    signal clk: std_ulogic;
    signal rst_n: std_ulogic;
    signal init: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal din: std_ulogic;
    signal seen: std_ulogic;

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
        info("Starting tb_programmable_sequence_detector");

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;
                                                                

    checker: process
        type arr_slv is array (natural range <>) of init'subtype;

        constant PROPAGATION_TIME: time := 1 ns;
        variable random: RandomPType;
        variable init_reg: init'subtype;
        variable shift_reg: init'subtype;
        variable din_count: natural range 0 to DATA_WIDTH;
        variable expected_seen: std_ulogic;

        procedure wait_clk_cycles(n: positive) is begin
            for i in 1 to n loop
                wait until rising_edge(clk);
            end loop;
            wait for PROPAGATION_TIME;
        end procedure;

        procedure reset_module is begin
            rst_n <= '0';
            wait_clk_cycles(1);
            -- Initialise the module
            init_reg := init;
        end procedure;

        impure function get_expected_sequence return std_ulogic is begin
            if rst_n = '0' then
                init_reg := init;
                din_count := 0;
                return '0';
            else
                if din_count < din_count'subtype'high then
                    din_count := din_count + 1;
                end if;
                shift_reg := shift_reg(shift_reg'high - 1 downto 0) & din;
            end if;

            if (shift_reg = init_reg) and (din_count = din_count'subtype'high) then
                return '1';
            else
                return '0';
            end if;
        end function;

        procedure set_and_check_sequence(
            init_sequence: arr_slv;
            reset_n_sequence, din_sequence, expected_output_sequence: std_ulogic_vector
        ) is begin
            for i in din_sequence'low to din_sequence'high loop
                rst_n <= reset_n_sequence(i);
                init <= init_sequence(i) when (i <= init_sequence'high) else init_sequence(init_sequence'high);
                din <= din_sequence(i);
                wait_clk_cycles(1);
                expected_seen := expected_output_sequence(i);
                check_equal(got => seen, expected => expected_seen, msg => "seen for given din " & to_string(din) & " at index " & to_string(i));
            end loop;
        end procedure;

        procedure test_example_1 is
            constant RESET_N_SEQUENCE: std_ulogic_vector := "011111111111";
            constant DIN_SEQUENCE: std_ulogic_vector := "011011110111";
            constant INIT_SEQUENCE: arr_slv := (0 => "11011");
            constant EXPECTED_OUTPUT_SEQUENCE: std_ulogic_vector := "000001000010";
        begin
            info("1.0) test_example_1");

            reset_module;

            set_and_check_sequence(
                init_sequence => INIT_SEQUENCE,
                reset_n_sequence => RESET_N_SEQUENCE,
                din_sequence => DIN_SEQUENCE,
                expected_output_sequence => EXPECTED_OUTPUT_SEQUENCE
            );
        end procedure;

        procedure test_example_2 is
            constant RESET_N_SEQUENCE: std_ulogic_vector := "010111111111";
            constant DIN_SEQUENCE: std_ulogic_vector := "011011110111";
            constant INIT_SEQUENCE: arr_slv := ("11011", "11110");
            constant EXPECTED_OUTPUT_SEQUENCE: std_ulogic_vector := "000000001000";
        begin
            info("2.0) test_example_2");

            reset_module;

            set_and_check_sequence(
                init_sequence => INIT_SEQUENCE,
                reset_n_sequence => RESET_N_SEQUENCE,
                din_sequence => DIN_SEQUENCE,
                expected_output_sequence => EXPECTED_OUTPUT_SEQUENCE
            );
        end procedure;

        procedure test_example_3 is
            constant RESET_N_SEQUENCE: std_ulogic_vector := "000111111111";
            constant DIN_SEQUENCE: std_ulogic_vector := "011011110111";
            constant INIT_SEQUENCE: arr_slv := ("11011", "11110", "00011");
            constant EXPECTED_OUTPUT_SEQUENCE: DIN_SEQUENCE'subtype := (others => '0');
        begin
            info("3.0) test_example_3");

            reset_module;

            set_and_check_sequence(
                init_sequence => INIT_SEQUENCE,
                reset_n_sequence => RESET_N_SEQUENCE,
                din_sequence => DIN_SEQUENCE,
                expected_output_sequence => EXPECTED_OUTPUT_SEQUENCE
            );
        end procedure;

        procedure test_random_values is begin
            info("4.0) test_random_values");

            reset_module;

            for i in 1 to 1000 loop
                rst_n <= random.DistSl(weight => RESET_N_WEIGHT);
                init <= random.RandSlv(Size => init'length);
                din <= random.DistSl(weight => WEIGHT_50_PERCENT);
                wait_clk_cycles(1);
                expected_seen := get_expected_sequence;
                check_equal(got => seen, expected => expected_seen, msg => "Failed for random din " & to_string(din) & " init " & to_string(init));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_example_2") then
                test_example_2;
            elsif run("test_example_3") then
                test_example_3;
            elsif run("test_random_values") then
                test_random_values;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    programmable_sequence_detector_inst: entity work.programmable_sequence_detector
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            init => init,
            din => din,
            seen => seen
        );
end architecture;
