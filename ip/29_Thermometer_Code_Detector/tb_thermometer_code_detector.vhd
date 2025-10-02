--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question
--!  @details    VHDL module for Thermometer Code Detector
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

entity tb_thermometer_code_detector is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_thermometer_code_detector is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 8;
    signal codeIn: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal isThermometer: std_ulogic;

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_thermometer_code_detector" & LF);

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        info("Simulation done, all tests passed!");

        test_runner_cleanup(runner);
        wait;
    end process;

    checker: process
        constant PROPAGATION_TIME: time := 1 ns;
        variable random: RandomPType;
        variable expected_isThermometer: std_ulogic;

        impure function is_valid_thermometer(code: std_ulogic_vector) return boolean is
            variable seen_zero_after_one: boolean := false;
        begin
            if code(0) = '0' then
                return false;
            elsif code = (code'range => '1') then
                return true;
            end if;

            for i in 1 to code'high loop
                if code(i) = '0' and code(i - 1) = '1' then
                    seen_zero_after_one := true;
                elsif code(i) = '1' and seen_zero_after_one then
                    return false;
                end if;
            end loop;

            return true;
        end function;

        procedure test_example_1 is
            type test_vector_t is record
                code: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
                expected: std_ulogic;
            end record;

            type test_data_array_t is array(natural range <>) of test_vector_t;

            constant TEST_DATA: test_data_array_t := (
                (code => "00000001", expected => '1'), -- Valid thermometer code (1)
                (code => "00000011", expected => '1'), -- Valid thermometer code (3)
                (code => "00000111", expected => '1'), -- Valid thermometer code (7)
                (code => "00001111", expected => '1'), -- Valid thermometer code (15)
                (code => "00000000", expected => '0'), -- Invalid: LSB is 0
                (code => "00000101", expected => '0'), -- Invalid: gap in 1s
                (code => "00001101", expected => '0'), -- Invalid: gap in 1s
                (code => "10000001", expected => '0')  -- Invalid: 1s not continuous from LSB
            );
        begin
            info("1.0) test_example_1 - Basic thermometer code tests");

            for i in TEST_DATA'range loop
                codeIn <= TEST_DATA(i).code;
                wait for PROPAGATION_TIME;
                check_equal(
                    got => isThermometer,
                    expected => TEST_DATA(i).expected,
                    msg => "Test case " & to_string(i) & ": " & to_string(TEST_DATA(i).code)
                );
            end loop;
        end procedure;

        procedure test_all_zeroes is begin
            info("2.0) test_all_zeroes - Should not be a valid thermometer code");

            codeIn <= (others => '0');
            wait for PROPAGATION_TIME;
            check_equal(
                got => isThermometer,
                expected => '0',
                msg => "All zeros test"
            );
        end procedure;

        procedure test_all_ones is begin
            info("3.0) test_all_ones - Should be a valid thermometer code");

            codeIn <= (others => '1');
            wait for PROPAGATION_TIME;
            check_equal(
                got => isThermometer,
                expected => '1',
                msg => "All ones test"
            );
        end procedure;

        -- Generate all valid thermometer codes for the given width
        procedure test_all_valid_thermometer_codes is begin
            info("4.0) test_all_valid_thermometer_codes");

            -- Loop through all valid patterns (continuous 1s from LSB)
            for i in 0 to DATA_WIDTH - 1 loop
                -- Create pattern with i+1 ones from LSB
                codeIn <= (others => '0');
                for j in 0 to i loop
                    codeIn(j) <= '1';
                end loop;

                wait for PROPAGATION_TIME;
                check_equal(
                    got => isThermometer,
                    expected => '1',
                    msg => "Valid thermometer code test: " & to_string(i+1) & " ones"
                );
            end loop;
        end procedure;

        procedure test_random is
            variable input_code: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
            variable coverage_model: CovPType;
            constant NUM_PATTERNS: integer := 2**DATA_WIDTH;
            constant NUM_BINS: natural := 8;
            constant BIN_SIZE: natural := NUM_PATTERNS / NUM_BINS;
            variable is_thermometer_code_v: boolean;
            variable valid_count, invalid_count: natural := 0;
        begin
            info("5.0) test_random - Random code testing with coverage");

            coverage_model.SetName("Thermometer Code Coverage");

            -- Add bins for special cases
            coverage_model.AddBins(Name => "All Zeros", CovBin => GenBin(Min => 0, Max => 0, NumBin => 1));
            coverage_model.AddBins(Name => "All Ones", CovBin => GenBin(Min => 2**DATA_WIDTH - 1, Max => 2**DATA_WIDTH - 1, NumBin => 1));

            -- Add equal-sized bins across the input range
            for i in 0 to NUM_BINS - 2 loop
                coverage_model.AddBins(
                    Name => "Range " & to_string(i * BIN_SIZE) & " to " & to_string((i + 1) * BIN_SIZE - 1),
                    CovBin => GenBin(Min => i * BIN_SIZE, Max => (i + 1) * BIN_SIZE - 1, NumBin => 1)
                );
            end loop;

            -- Add bins for valid thermometer patterns (2^0 to 2^DATA_WIDTH - 1)
            for i in 0 to DATA_WIDTH - 1 loop
                coverage_model.AddBins(
                    Name => "Valid thermometer " & to_string(2**i - 1),
                    CovBin => GenBin(Min => 2**i - 1, Max => 2**i - 1, NumBin => 1)
                );
            end loop;

            for i in 1 to 1000 loop
                input_code := random.RandSlv(Size => DATA_WIDTH);
                coverage_model.ICover(CovPoint => to_integer(unsigned(input_code)));

                codeIn <= input_code;
                wait for PROPAGATION_TIME;

                is_thermometer_code_v := is_valid_thermometer(code => input_code);
                expected_isThermometer := '1' when is_thermometer_code_v else '0';

                if is_thermometer_code_v then
                    valid_count := valid_count + 1;
                else
                    invalid_count := invalid_count + 1;
                end if;

                check_equal(
                    got => isThermometer,
                    expected => expected_isThermometer,
                    msg => "Random test for code: " & to_string(input_code)
                );
            end loop;

            info("Valid patterns tested: " & to_string(valid_count));
            info("Invalid patterns tested: " & to_string(invalid_count));
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
            elsif run("test_all_valid_thermometer_codes") then
                test_all_valid_thermometer_codes;
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    dut: entity work.thermometer_code_detector
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            codeIn => codeIn,
            isThermometer => isThermometer
        );
end architecture;
