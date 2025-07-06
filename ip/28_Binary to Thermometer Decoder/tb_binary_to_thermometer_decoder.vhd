--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 28
--!  @details    VHDL module for Binary to Thermometer Decoder
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

use work.utils_pkg.all;
use work.tb_utils.all;

entity tb_binary_to_thermometer_decoder is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_binary_to_thermometer_decoder is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant THERMOMETER_WIDTH: positive := 256;
    constant BINARY_WIDTH: positive := to_bits(THERMOMETER_WIDTH);
    signal din: std_ulogic_vector(BINARY_WIDTH - 1 downto 0) := (others => '0');
    signal dout: std_ulogic_vector(THERMOMETER_WIDTH - 1 downto 0);

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_binary_to_thermometer_decoder");

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
        variable expected_dout: std_ulogic_vector(dout'range);

        procedure check_thermometer(binary_value: natural) is begin
            expected_dout := (others => '0');
            expected_dout(binary_value downto 0) := (others => '1');
            check_equal(
                got => dout,
                expected => expected_dout,
                msg => "dout - thermometer code for binary = " & to_string(binary_value)
            );
        end procedure;

        procedure test_example_1 is
            constant TEST_CASES: integer_vector := (
                (0 => 0),   -- Single 1 at LSB (2^0 = 1 bit)
                (1 => 1),   -- Two 1s at LSB (2^1 = 2 bits)
                (2 => 2),   -- Four 1s at LSB (2^2 = 4 bits)
                (3 => 3),   -- Eight 1s at LSB (2^3 = 8 bits)
                (4 => 4),   -- Sixteen 1s at LSB (2^4 = 16 bits)
                (5 => 5),   -- 32 1s at LSB (2^5 = 32 bits)
                (6 => 6),   -- 64 1s at LSB (2^6 = 64 bits)
                (7 => 7),   -- 128 1s at LSB (2^7 = 128 bits)
                (8 => 8)    -- 256 1s at LSB (2^8 = 256 bits, all 1s)
            );
            constant EXPECTED_THERMOMETER: integer_vector := (
                (0 => 1),   -- 1 bit
                (1 => 3),   -- 2 bits
                (2 => 7),   -- 4 bits
                (3 => 15),  -- 8 bits
                (4 => 31),  -- 16 bits
                (5 => 63),  -- 32 bits
                (6 => 127), -- 64 bits
                (7 => 255), -- 128 bits
                (8 => 511)  -- All bits set for 256 bits
            );
        begin
            info("1.0) test_example_1");

            for i in TEST_CASES'low to TEST_CASES'high loop
                din <= std_ulogic_vector(to_unsigned(TEST_CASES(i), din'length));
                wait for PROPAGATION_TIME;
                check_equal(
                    got => dout,
                    expected => EXPECTED_THERMOMETER(i),
                    msg => "dout"
                );
            end loop;
        end procedure;

        procedure test_all_zeroes is begin
            info("2.0) test_all_zeroes");

            din <= (others => '0');
            wait for PROPAGATION_TIME;
            check_thermometer(binary_value => 0);
        end procedure;

        procedure test_all_ones is begin
            info("3.0) test_all_ones");

            din <= (others => '1');
            wait for PROPAGATION_TIME;
            check_thermometer(binary_value => 2**BINARY_WIDTH - 1);
        end procedure;

        procedure test_random is
            variable binary_value: natural;
            variable coverage_model: CovPType;
            constant NUM_BINS: natural := 16;  -- Divide the input range into 16 equal bins
            constant BIN_SIZE: natural := (2**BINARY_WIDTH) / NUM_BINS;
        begin
            info("4.0) test_random");

            coverage_model.SetName("Binary Input Coverage");

            -- Special cases
            coverage_model.AddBins(Name => "All Zeros", CovBin => GenBin(Min => 0, Max => 0, NumBin => 1));
            coverage_model.AddBins(Name => "All Ones", CovBin => GenBin(Min => 2**BINARY_WIDTH - 1, Max => 2**BINARY_WIDTH - 1, NumBin => 1));

            -- Add equal-sized bins across the input range
            for i in 0 to NUM_BINS - 2 loop
                coverage_model.AddBins(
                    Name => "Range " & to_string(i * BIN_SIZE + 1) & " to " & to_string((i + 1) * BIN_SIZE),
                    CovBin => GenBin(Min => i * BIN_SIZE + 1, Max => (i + 1) * BIN_SIZE, NumBin => 1)
                );
            end loop;

            for i in 1 to 1000 loop
                binary_value := random.RandInt(Min => 0, Max => 2**BINARY_WIDTH - 1);
                coverage_model.ICover(CovPoint => binary_value);

                din <= std_ulogic_vector(to_unsigned(binary_value, din'length));
                wait for PROPAGATION_TIME;
                check_thermometer(binary_value => binary_value);
            end loop;

            info(
                "Coverage percentage: " & to_string(coverage_model.GetCov, "%.2f") & " %" &
                " (bins covered: " & to_string(coverage_model.GetTotalCovCount) & "/" & to_string(coverage_model.GetNumBins) & ")"
            );
            info("Coverage details:");
            coverage_model.WriteBin;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_all_zeroes") then
                test_all_zeroes;
            elsif run("test_all_ones") then
                test_all_ones;
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    dut: entity work.binary_to_thermometer_decoder
        generic map (
            THERMOMETER_WIDTH => THERMOMETER_WIDTH
        )
        port map (
            din => din,
            dout => dout
        );
end architecture;
