--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 34
--!  @details    VHDL module for Mealy Finite State Machine
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
use osvvm.CoveragePkg.all;

use work.tb_utils.all;

entity tb_mealy_finite_state_machine is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_mealy_finite_state_machine is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din: std_ulogic := '0';
    signal cen: std_ulogic := '0';
    signal doutx: std_ulogic;
    signal douty: std_ulogic;

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
        info("Starting tb_mealy_finite_state_machine");

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
        variable coverage_model: CovPType;

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
        end procedure;

        procedure test_example_1 is
            constant RST_N_SEQUENCE: std_ulogic_vector := (
                0 => '0', 1 to 7 => '1', 8 => '0', 9 to 13 => '1'
            );
            constant DIN_SEQUENCE: RST_N_SEQUENCE'subtype := (
                0 to 1 => '0', 2 to 8 => '1', 9 => '0', 10 => '1', others => '0'
            );
            constant CEN_SEQUENCE: RST_N_SEQUENCE'subtype := (
                9 | 12 to 13 => '0', others => '1'
            );
            constant EXPECTED_DOUTX_SEQUENCE: RST_N_SEQUENCE'subtype := "01011111000000";
            constant EXPECTED_DOUTY_SEQUENCE: RST_N_SEQUENCE'subtype := "00001111000000";
        begin
            info("1.0) test_example_1" & LF);

            for i in RST_N_SEQUENCE'range loop
                rst_n <= RST_N_SEQUENCE(i);
                din <= DIN_SEQUENCE(i);
                cen <= CEN_SEQUENCE(i);
                wait_clk_cycles(1);
                check_equal(got => doutx, expected => EXPECTED_DOUTX_SEQUENCE(i), msg => "doutx at cycle " & to_string(i));
                check_equal(got => douty, expected => EXPECTED_DOUTY_SEQUENCE(i), msg => "douty at cycle " & to_string(i));
            end loop;

            info("test_example_1 passed!" & LF);
        end procedure;

        procedure test_zeros is
            constant REPETITIONS: positive := 10;
        begin
            info("2.0) test_zeros" & LF);
            reset_module;
            start_module;

            cen <= '1';
            din <= '0';
            -- After reset, din_reg='0' already counts as first value
            -- So: i=1 -> 2 consecutive 0s (doutx='1'), i=2 -> 3 consecutive 0s (douty='1')
            for i in 1 to REPETITIONS loop
                wait_clk_cycles(1);
                check_equal(got => doutx, expected => '1', msg => "doutx at cycle " & to_string(i));
                check_equal(got => douty, expected => (i >= 2), msg => "douty at cycle " & to_string(i));
            end loop;

            info("test_zeros passed!" & LF);
        end procedure;

        procedure test_ones is
            constant REPETITIONS: positive := 10;
        begin
            info("3.0) test_ones" & LF);
            reset_module;
            start_module;

            cen <= '1';
            din <= '1';
            for i in 1 to REPETITIONS loop
                wait_clk_cycles(1);
                check_equal(got => doutx, expected => (i >= 2), msg => "doutx at cycle " & to_string(i));
                check_equal(got => douty, expected => (i >= 3), msg => "douty at cycle " & to_string(i));
            end loop;

            info("test_ones passed!" & LF);
        end procedure;

        procedure test_random is
            constant CEN_WEIGHT: NaturalVSlType(std_ulogic'('0') to '1') := ('0' => 20, '1' => 80);
            constant TOTAL_ITERATIONS: positive := 1000;

            variable din_history: std_ulogic_vector(2 downto 0) := (others => '0');
            variable history_count: natural := 0;
            variable expected_doutx, expected_douty: std_ulogic;
        begin
            info("4.0) test_random" & LF);

            coverage_model.SetName("Random Test Coverage Model");

            coverage_model.AddBins(Name => "rst_n", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "cen", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "din", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "doutx", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "douty", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));

            rst_n <= '0';
            cen <= '0';
            din <= '0';
            din_history := (others => '0');
            history_count := 0;
            wait_clk_cycles(1);

            for iteration in 1 to TOTAL_ITERATIONS loop
                rst_n <= random.DistSl(weight => RESET_N_WEIGHT);
                cen <= random.DistSl(weight => CEN_WEIGHT);
                din <= to_01(random.RandSl);

                wait_clk_cycles(1);

                -- Update coverage
                coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & rst_n)));
                coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & cen)));
                coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & din)));

                expected_doutx := '0';
                expected_douty := '0';

                if rst_n = '0' then
                    din_history := (others => '0');
                    history_count := 0;
                else
                    din_history := din_history(din_history'high - 1 downto din_history'low) & din;
                    history_count := history_count + 1;

                    -- Check for 2 consecutive same values (doutx): reset value (din_reg='0') counts as first
                    -- So history_count=1 means we have 2 values (reset + current)
                    if history_count >= 1 then
                        if din_history(1 downto 0) = "00" or din_history(1 downto 0) = "11" then
                            expected_doutx := cen;
                        end if;
                    end if;

                    -- Check for 3 consecutive same values (douty): reset value counts as first
                    -- So history_count=2 means we have 3 values (reset + 2 new inputs)
                    if history_count >= 2 then
                        if din_history = "000" or din_history = "111" then
                            expected_douty := cen;
                        end if;
                    end if;
                end if;

                coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & doutx)));
                coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & douty)));

                check_equal(got => doutx, expected => expected_doutx, msg => "doutx at iteration " & to_string(iteration));
                check_equal(got => douty, expected => expected_douty, msg => "douty at iteration " & to_string(iteration));
            end loop;

            info(
                "Coverage percentage: " & to_string(coverage_model.GetCov, "%.2f") & " %" &
                " (bins covered: " & to_string(coverage_model.GetTotalCovCount) & "/" & to_string(coverage_model.GetNumBins) & ")" & LF
            );
            info("Coverage details:" & LF);
            coverage_model.WriteBin;

            info("test_random passed (" & to_string(TOTAL_ITERATIONS) & " iterations) !" & LF);
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_zeros") then
                test_zeros;
            elsif run("test_ones") then
                test_ones;
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    DuT: entity work.mealy_finite_state_machine
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            cen => cen,
            doutx => doutx,
            douty => douty
        );
end architecture;
