--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 31
--!  @details    VHDL module for Configurable _LFSR
--! ----------------------------------------------------------------------------

-- vunit: run_all_in_same_sim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.RandomPType;
use osvvm.CoveragePkg.all;

use work.tb_utils.all;
use work.utils_pkg.all;

entity tb_configurable_lfsr is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_configurable_lfsr is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 8;

    signal clk: std_ulogic;
    signal rst_n: std_ulogic;
    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal tap: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal dout: std_ulogic_vector(DATA_WIDTH - 1 downto 0);

    signal expected_dout: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
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
        info("Starting tb_configurable_lfsr");

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Expected LFSR model
    ------------------------------------------------------------
    expected: process(clk)
        variable shift_reg: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        variable tap_reg: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        variable feedback: std_ulogic := '0';
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                expected_dout <= din;
                shift_reg := din;
                tap_reg := tap;
            else
                feedback := '0';
                for i in DATA_WIDTH - 1 downto 0 loop
                    if tap_reg(i) then
                        feedback := feedback xor expected_dout(i);
                    end if;
                end loop;

                shift_reg := shift_reg(shift_reg'high - 1 downto shift_reg'low) & feedback;
                expected_dout <= shift_reg;
            end if;
        end if;
    end process;
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Checker
    ------------------------------------------------------------
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

        procedure reset_and_start_module is begin
            rst_n <= '0';
            wait_clk_cycles(1);
            rst_n <= '1';
            wait_clk_cycles(1);
        end procedure;

        procedure test_example_1 is
            type data_array is array (natural range <>) of std_ulogic_vector(DATA_WIDTH - 1 downto 0);

            -- Is just the same value for the entire duration
            constant DIN_SEQUENCE: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := x"01";
            constant TAP_SEQUENCE: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := x"0e";
            constant DOUT_EXPECTED: data_array := (
                0 => x"01",
                1 => x"02",
                2 => x"05",
                3 => x"0b",
                4 => x"16",
                5 => x"2c",
                6 => x"58",
                7 => x"b1",
                8 => x"62",
                9 => x"c5"
            );
            constant RST_N_SEQUENCE: std_ulogic_vector(DOUT_EXPECTED'range) := (0 => '0', others => '1');
            variable expected_dout_v: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        begin
            info("1.0) test_example_1" & LF);

            din <= DIN_SEQUENCE;
            tap <= TAP_SEQUENCE;

            for i in DIN_SEQUENCE'subtype'low to DIN_SEQUENCE'subtype'high loop
                rst_n <= RST_N_SEQUENCE(i);
                expected_dout_v := DOUT_EXPECTED(i);
                wait_clk_cycles(1);
                check_equal(got => dout, expected => expected_dout_v, msg => "dout @ cycle " & to_string(i));
            end loop;

            info("1.0) test_example_1 passed" & LF);
        end procedure;

        procedure test_all_zeros is
            constant TEST_REPETITIONS: positive := 10;
        begin
            info(
                "2.0) test_all_zeros" & LF &
                "Only 0s should be output regardless of the taps" & LF
            );

            din <= (others => '0');
            tap <= (others => '0');

            reset_and_start_module;

            for i in 0 to TEST_REPETITIONS - 1 loop
                check_equal(got => dout, expected => std_ulogic_vector'(dout'range => '0'), msg => "dout @ cycle " & to_string(i));
                wait_clk_cycles(1);
            end loop;

            info("2.0) test_all_zeros passed" & LF);
        end procedure;

        procedure test_all_ones is
            constant TEST_REPETITIONS: positive := 10;
        begin
            info("3.0) test_all_ones" & LF);

            din <= (others => '1');
            tap <= (others => '1');

            reset_and_start_module;

            for i in 0 to TEST_REPETITIONS - 1 loop
                check_equal(got => dout, expected => expected_dout, msg => "dout @ cycle " & to_string(i));
                wait_clk_cycles(1);
            end loop;

            info("3.0) test_all_ones passed" & LF);
        end procedure;

        procedure test_wrap_around is
            constant WRAP_AROUND_AMOUNT: positive := 2;
        begin
            info(
                "4.0) test_wrap_around" & LF &
                "Due to pseudo-random nature, we should see values repeating after a while" & LF
            );

            din <= random.RandSlv(Min => 1, Max => 2**DATA_WIDTH - 2, Size => DATA_WIDTH);
            tap <= random.RandSlv(Min => 1, Max => 2**DATA_WIDTH - 2, Size => DATA_WIDTH);

            reset_and_start_module;

            for i in 0 to 2**dout'length * WRAP_AROUND_AMOUNT - 1 loop
                check_equal(got => dout, expected => expected_dout, msg => "dout @ cycle " & to_string(i));
                wait_clk_cycles(1);
            end loop;

            info("4.0) test_wrap_around passed" & LF);
        end procedure;

        procedure test_random is
            constant TEST_REPETITIONS: positive := 1000;
        begin
            info("5.0) test_random" & LF);

            coverage_model.SetName("Random Test Coverage Model");

            coverage_model.AddBins(Name => "Reset_Active", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "rst_n", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "din", CovBin => GenBin(Min => 0, Max => 2**DATA_WIDTH - 1, NumBin => 16));
            coverage_model.AddBins(Name => "tap", CovBin => GenBin(Min => 0, Max => 2**DATA_WIDTH - 1, NumBin => 16));
            coverage_model.AddBins(Name => "dout", CovBin => GenBin(Min => 0, Max => 2**DATA_WIDTH - 1, NumBin => 16));

            for i in 0 to TEST_REPETITIONS - 1 loop
                rst_n <= random.DistSl(Weight => RESET_N_WEIGHT);
                din <= random.RandSlv(Size => DATA_WIDTH);
                tap <= random.RandSlv(Size => DATA_WIDTH);

                wait_clk_cycles(1);
                coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & rst_n)));
                coverage_model.ICover(CovPoint => to_integer(unsigned(din)));
                coverage_model.ICover(CovPoint => to_integer(unsigned(tap)));
                coverage_model.ICover(CovPoint => to_integer(unsigned(dout)));

                check_equal(got => dout, expected => expected_dout, msg => "dout @ cycle " & to_string(i));
            end loop;

            info(
                "Coverage percentage: " & to_string(coverage_model.GetCov, "%.2f") & " %" &
                " (bins covered: " & to_string(coverage_model.GetTotalCovCount) & "/" & to_string(coverage_model.GetNumBins) & ")" & LF
            );
            info("Coverage details:" & LF);
            coverage_model.WriteBin;

            info("5.0) test_random passed" & LF);
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_all_zeros") then
                test_all_zeros;
            elsif run("test_all_ones") then
                test_all_ones;
            elsif run("test_wrap_around") then
                test_wrap_around;
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;
    ------------------------------------------------------------

    configurable_lfsr_inst : entity work.configurable_lfsr
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            tap => tap,
            dout => dout
        );
end architecture;
