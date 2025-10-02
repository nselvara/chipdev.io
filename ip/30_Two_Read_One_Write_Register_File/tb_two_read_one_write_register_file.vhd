--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 30
--!  @details    VHDL module for Two Read One Write Register File
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

entity tb_two_read_one_write_register_file is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_two_read_one_write_register_file is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 16;
    constant ADDRESS_WIDTH: positive := 5;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal wad1: std_ulogic_vector(ADDRESS_WIDTH - 1 downto 0) := (others => '0');
    signal rad1: std_ulogic_vector(ADDRESS_WIDTH - 1 downto 0) := (others => '0');
    signal rad2: std_ulogic_vector(ADDRESS_WIDTH - 1 downto 0) := (others => '0');
    signal wen1: std_ulogic := '0';
    signal ren1: std_ulogic := '0';
    signal ren2: std_ulogic := '0';
    signal dout1: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal dout2: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal collision: std_ulogic;

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
        info("Starting tb_two_read_one_write_register_file" & LF);

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;

    checker: process
        type memory_array is array (0 to 2**ADDRESS_WIDTH - 1) of std_ulogic_vector(DATA_WIDTH - 1 downto 0);

        constant PROPAGATION_TIME: time := 1 ns;
        constant ZERO_WORD: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

        variable random: RandomPType;
        variable coverage_model: CovPType;

        variable expected_memory: memory_array := (others => (others => '0'));
        variable expected_dout1: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        variable expected_dout2: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        variable expected_collision: std_ulogic;

        procedure wait_clk_cycles(n: positive) is begin
            for i in 1 to n loop
                wait until rising_edge(clk);
            end loop;
            wait for PROPAGATION_TIME;
        end procedure;

        procedure calculated_expected is
            variable control_combo: natural;
        begin
            -- Cover reset state
            coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & rst_n)));

            -- Cover data values
            coverage_model.ICover(CovPoint => to_integer(unsigned(din)));

            -- Cover addresses separately
            coverage_model.ICover(CovPoint => to_integer(unsigned(wad1)));
            coverage_model.ICover(CovPoint => to_integer(unsigned(rad1)));
            coverage_model.ICover(CovPoint => to_integer(unsigned(rad2)));

            expected_dout1 := (others => '0');
            expected_dout2 := (others => '0');
            expected_collision := '0';

            if rst_n = '0' then
                expected_memory := (others => (others => '0'));
            else
                -- Check for collision cases and cover them with specific coverage points
                if (rad1 = rad2) and (?? (ren1 and ren2)) then
                    expected_collision := '1';
                    coverage_model.ICover(CovPoint => to_integer(unsigned(rad1)));
                    coverage_model.ICover(CovPoint => to_integer(unsigned(rad2)));
                    coverage_model.ICover(CovPoint => to_integer(unsigned'(ren1 & ren2)));
                elsif (rad1 = wad1) and (?? (wen1 and ren1)) then
                    expected_collision := '1';
                    coverage_model.ICover(CovPoint => to_integer(unsigned(wad1)));
                    coverage_model.ICover(CovPoint => to_integer(unsigned(rad1)));
                elsif (rad2 = wad1) and (?? (wen1 and ren2)) then
                    expected_collision := '1';
                    coverage_model.ICover(CovPoint => to_integer(unsigned(wad1)));
                    coverage_model.ICover(CovPoint => to_integer(unsigned(rad2)));
                end if;

                control_combo := 0;
                control_combo := control_combo + 1 when wen1;
                control_combo := control_combo + 2 when ren1;
                control_combo := control_combo + 4 when ren2;

                coverage_model.ICover(CovPoint => control_combo);

                if not expected_collision then
                    if wen1 then
                        expected_memory(to_integer(unsigned(wad1))) := din;
                    end if;

                    if ren1 then
                        expected_dout1 := expected_memory(to_integer(unsigned(rad1)));
                    end if;

                    if ren2 then
                        expected_dout2 := expected_memory(to_integer(unsigned(rad2)));
                    end if;
                end if;
            end if;
        end procedure;

        procedure check_outputs(
            exp_collision: std_ulogic;
            exp_dout1: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
            exp_dout2: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
            msg: string := ""
        ) is begin
            expected_collision := exp_collision;
            expected_dout1 := exp_dout1;
            expected_dout2 := exp_dout2;

            check_equal(got => collision, expected => expected_collision, msg => "Collision " & msg);
            check_equal(got => dout1, expected => expected_dout1, msg => "Dout1 " & msg);
            check_equal(got => dout2, expected => expected_dout2, msg => "Dout2 " & msg);
        end procedure;

        procedure reset_module is begin
            wen1 <= '0';
            ren1 <= '0';
            ren2 <= '0';

            rst_n <= '0';
            wait_clk_cycles(1);

            expected_collision := '0';
            expected_dout1 := ZERO_WORD;
            expected_dout2 := ZERO_WORD;

            check_outputs(expected_collision, expected_dout1, expected_dout2, msg => " - After reset");
        end procedure;

        procedure start_module is begin
            rst_n <= '1';
            wait_clk_cycles(1);
        end procedure;

        procedure test_example_1 is
            type address_array_t is array (natural range <>) of std_ulogic_vector(ADDRESS_WIDTH-  1 downto 0);
            type data_array is array (natural range <>) of std_ulogic_vector(DATA_WIDTH - 1 downto 0);

            -- Reset sequences
            constant RST_N_SEQUENCE: std_ulogic_vector := "0111111111";

            -- Address sequences
            constant RAD1_SEQUENCE: address_array_t := (
                0 => std_ulogic_vector(to_unsigned(16#00#, ADDRESS_WIDTH)),
                1 => std_ulogic_vector(to_unsigned(16#00#, ADDRESS_WIDTH)),
                2 => std_ulogic_vector(to_unsigned(16#00#, ADDRESS_WIDTH)),
                3 => std_ulogic_vector(to_unsigned(16#00#, ADDRESS_WIDTH)),
                4 => std_ulogic_vector(to_unsigned(16#00#, ADDRESS_WIDTH)),
                5 => std_ulogic_vector(to_unsigned(16#04#, ADDRESS_WIDTH)),
                6 => std_ulogic_vector(to_unsigned(16#03#, ADDRESS_WIDTH)),
                7 => std_ulogic_vector(to_unsigned(16#02#, ADDRESS_WIDTH)),
                8 => std_ulogic_vector(to_unsigned(16#01#, ADDRESS_WIDTH)),
                9 => std_ulogic_vector(to_unsigned(16#01#, ADDRESS_WIDTH))
            );
            -- Is the same as RAD1_SEQUENCE
            constant RAD2_SEQUENCE: address_array_t := RAD1_SEQUENCE;

            constant WAD1_SEQUENCE: address_array_t := (
                0 => std_ulogic_vector(to_unsigned(16#0#, ADDRESS_WIDTH)),
                1 => std_ulogic_vector(to_unsigned(16#1#, ADDRESS_WIDTH)),
                2 => std_ulogic_vector(to_unsigned(16#2#, ADDRESS_WIDTH)),
                3 => std_ulogic_vector(to_unsigned(16#3#, ADDRESS_WIDTH)),
                4 => std_ulogic_vector(to_unsigned(16#4#, ADDRESS_WIDTH)),
                5 => std_ulogic_vector(to_unsigned(16#4#, ADDRESS_WIDTH)),
                6 => std_ulogic_vector(to_unsigned(16#3#, ADDRESS_WIDTH)),
                7 => std_ulogic_vector(to_unsigned(16#2#, ADDRESS_WIDTH)),
                8 => std_ulogic_vector(to_unsigned(16#1#, ADDRESS_WIDTH)),
                9 => std_ulogic_vector(to_unsigned(16#1#, ADDRESS_WIDTH))
            );

            constant DIN_SEQUENCE: data_array := (
                0 => std_ulogic_vector(to_unsigned(16#0E#, DATA_WIDTH)),
                1 => std_ulogic_vector(to_unsigned(16#80#, DATA_WIDTH)),
                2 => std_ulogic_vector(to_unsigned(16#FF#, DATA_WIDTH)),
                3 => std_ulogic_vector(to_unsigned(16#01#, DATA_WIDTH)),
                4 => std_ulogic_vector(to_unsigned(16#C8#, DATA_WIDTH)),
                5 => (others => '0'),
                6 => std_ulogic_vector(to_unsigned(16#FF#, DATA_WIDTH)),
                7 => (others => '0'),
                8 => std_ulogic_vector(to_unsigned(16#FF#, DATA_WIDTH)),
                9 => (others => '0')
            );

            -- Control signals
            constant REN1_SEQUENCE: std_ulogic_vector := "0000011111";
            constant REN2_SEQUENCE: std_ulogic_vector := "0000000011";
            constant WEN1_SEQUENCE: std_ulogic_vector := "0111100000";

            -- Expected collision signal
            constant COLLISION_EXP: std_ulogic_vector := "0000000001";
            constant DOUT1_EXP: data_array := (
                0 => (others => '0'),
                1 => (others => '0'),
                2 => (others => '0'),
                3 => (others => '0'),
                4 => (others => '0'),
                5 => (others => '0'),
                6 => std_ulogic_vector(to_unsigned(16#C8#, DATA_WIDTH)),
                7 => std_ulogic_vector(to_unsigned(16#01#, DATA_WIDTH)),
                8 => std_ulogic_vector(to_unsigned(16#FF#, DATA_WIDTH)),
                9 => (others => '0')
            );
            -- dout2 is always zero in this test
        begin
            info(
                "1.0) test_example_1 " & LF &
                "Register file operation with collision detection" & LF
            );

            for i in DIN_SEQUENCE'subtype'low to DIN_SEQUENCE'subtype'high loop
                rst_n <= RST_N_SEQUENCE(i);

                ren1 <= REN1_SEQUENCE(i);
                ren2 <= REN2_SEQUENCE(i);
                wen1 <= WEN1_SEQUENCE(i);

                rad1 <= RAD1_SEQUENCE(i);
                rad2 <= RAD2_SEQUENCE(i);
                wad1 <= WAD1_SEQUENCE(i);

                din <= DIN_SEQUENCE(i);

                check_outputs(
                    exp_collision => COLLISION_EXP(i),
                    exp_dout1 => DOUT1_EXP(i),
                    exp_dout2 => ZERO_WORD,
                    msg => " at cycle " & to_string(i)
                );
                wait_clk_cycles(1);
            end loop;

            info("test_example_1 completed successfully!" & LF);
        end procedure;

        procedure test_no_operation is
            constant TEST_REPETITIONS: natural := 10;
        begin
            info(
                "2.0) test_no_operation" & LF &
                "No read or write operations - Should retain previous state" & LF
            );

            reset_module;
            start_module;

            for i in 0 to TEST_REPETITIONS - 1 loop
                wad1 <= random.RandSlv(Size => ADDRESS_WIDTH);
                rad1 <= random.RandSlv(Size => ADDRESS_WIDTH);
                rad2 <= random.RandSlv(Size => ADDRESS_WIDTH);

                wait_clk_cycles(1);

                check_outputs(
                    exp_collision => '0',
                    exp_dout1 => ZERO_WORD,
                    exp_dout2 => ZERO_WORD,
                    msg => " should remain same with no operations"
                );
            end loop;

            info("test_no_operation completed successfully!" & LF);
        end procedure;

        procedure test_write_and_read_conflicts is
            constant TEST_REPETITIONS: natural := 10;
            variable random_address: std_ulogic_vector(ADDRESS_WIDTH - 1 downto 0);
        begin
            info(
                "3.0) test_write_and_read_conflicts" & LF &
                "Write and read same address simultaneously - Should not write" & LF
            );

            info(
                "3.1) Write and rad1 same address" & LF &
                "Should not write and read 0 on dout1"
            );

            reset_module;
            start_module;

            for i in 0 to TEST_REPETITIONS - 1 loop
                wen1 <= '1';
                ren1 <= '1';
                ren2 <= '0';

                din <= random.RandSlv(Size => DATA_WIDTH);
                random_address := random.RandSlv(Size => ADDRESS_WIDTH);
                wad1 <= random_address;
                rad1 <= random_address;

                wait_clk_cycles(1);

                check_outputs(
                    exp_collision => '1',
                    exp_dout1 => ZERO_WORD,
                    exp_dout2 => ZERO_WORD,
                    msg => " should remain same with write and read conflict"
                );
            end loop;

            info(
                "3.2) Write and rad2 same address " & LF &
                "Should not write and read 0 on dout2" & LF
            );

            reset_module;
            start_module;

            for i in 0 to TEST_REPETITIONS - 1 loop
                wen1 <= '1';
                ren1 <= '0';
                ren2 <= '1';

                din <= random.RandSlv(Size => DATA_WIDTH);
                random_address := random.RandSlv(Size => ADDRESS_WIDTH);
                wad1 <= random_address;
                rad2 <= random_address;

                wait_clk_cycles(1);

                check_outputs(
                    exp_collision => '1',
                    exp_dout1 => ZERO_WORD,
                    exp_dout2 => ZERO_WORD,
                    msg => " should remain same with write and read conflict"
                );
            end loop;

            info("test_write_and_read_conflicts completed successfully!" & LF);
        end procedure;

        procedure test_read_conflict is
            constant TEST_REPETITIONS: natural := 10;
            variable random_address: std_ulogic_vector(ADDRESS_WIDTH - 1 downto 0);
        begin
            info(
                "4.0) test_read_conflict " & LF &
                "When rad1 and rad2 are same address, should read 0 on both dout1 and dout2" & LF
            );

            wen1 <= '0';
            ren1 <= '0';
            ren2 <= '0';

            reset_module;
            start_module;

            for i in 0 to TEST_REPETITIONS - 1 loop
                wen1 <= '0';
                ren1 <= '1';
                ren2 <= '1';

                random_address := random.RandSlv(Size => ADDRESS_WIDTH);
                wad1 <= random.RandSlv(Size => ADDRESS_WIDTH);
                rad1 <= random_address;
                rad2 <= random_address;

                wait_clk_cycles(1);

                check_outputs(
                    exp_collision => '1',
                    exp_dout1 => ZERO_WORD,
                    exp_dout2 => ZERO_WORD,
                    msg => " should remain same with read conflict"
                );
            end loop;

            info("test_read_conflict completed successfully!" & LF);
        end procedure;

        procedure test_random_inputs is
            constant TEST_REPETITIONS: natural := 1000;
        begin
            info(
                "5.0) test_random_inputs" & LF &
                "Randomized read and write operations" & LF
            );

            coverage_model.SetName("Two Read One Write Register File Randomised Coverage");

            -- Add bins
            -- Reset
            coverage_model.AddBins(Name => "Reset_Active", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));

            -- Enable signals combinations
            coverage_model.AddBins(Name => "Write Enabled", CovBin => GenBin(Min => 1, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "Read1 Enabled", CovBin => GenBin(Min => 2, Max => 2, NumBin => 1));
            coverage_model.AddBins(Name => "Read2 Enabled", CovBin => GenBin(Min => 4, Max => 4, NumBin => 1));
            coverage_model.AddBins(Name => "Write and Read1 Enabled", CovBin => GenBin(Min => 3, Max => 3, NumBin => 1));
            coverage_model.AddBins(Name => "Write and Read2 Enabled", CovBin => GenBin(Min => 5, Max => 5, NumBin => 1));
            coverage_model.AddBins(Name => "Read1 and Read2 Enabled", CovBin => GenBin(Min => 6, Max => 6, NumBin => 1));
            coverage_model.AddBins(Name => "All Enabled", CovBin => GenBin(Min => 7, Max => 7, NumBin => 1));

            -- Data values
            coverage_model.AddBins(Name => "Data_All_Zeros", CovBin => GenBin(Min => 0, Max => 0, NumBin => 1));
            coverage_model.AddBins(Name => "Data_All_Ones", CovBin => GenBin(Min => 2**DATA_WIDTH - 1, Max => 2**DATA_WIDTH - 1, NumBin => 1));
            coverage_model.AddBins(Name => "Data_Mid_Range", CovBin => GenBin(Min => 1, Max => 2**DATA_WIDTH - 2, NumBin => 10));

            -- Addresses
            coverage_model.AddBins(Name => "Addr_Min", CovBin => GenBin(Min => 0, Max => 0, NumBin => 1));
            coverage_model.AddBins(Name => "Addr_Max", CovBin => GenBin(Min => 2**ADDRESS_WIDTH - 1, Max => 2**ADDRESS_WIDTH - 1, NumBin => 1));
            coverage_model.AddBins(Name => "Addr_Mid_Range", CovBin => GenBin(Min => 1, Max => 2**ADDRESS_WIDTH - 2, NumBin => 5));

            -- Collision cases
            coverage_model.AddBins(Name => "Read_Conflict", CovBin => GenBin(Min => to_integer(unsigned(rad1)), Max => to_integer(unsigned(rad1)), NumBin => 1));
            coverage_model.AddBins(Name => "Write_Read1_Conflict", CovBin => GenBin(Min => to_integer(unsigned(wad1)), Max => to_integer(unsigned(wad1)), NumBin => 1));
            coverage_model.AddBins(Name => "Write_Read2_Conflict", CovBin => GenBin(Min => to_integer(unsigned(wad1)), Max => to_integer(unsigned(wad1)), NumBin => 1));

            coverage_model.AddBins(Name => "Control_Combinations", CovBin => GenBin(Min => 0, Max => 7, NumBin => 8));

            wen1 <= '0';
            ren1 <= '0';
            ren2 <= '0';

            reset_module;
            start_module;

            for i in 0 to TEST_REPETITIONS - 1 loop
                rst_n <= random.DistSl(Weight => RESET_N_WEIGHT);

                wen1 <= random.RandSlv(Size => 1)(1);
                ren1 <= random.RandSlv(Size => 1)(1);
                ren2 <= random.RandSlv(Size => 1)(1);

                wad1 <= random.RandSlv(Size => ADDRESS_WIDTH);
                rad1 <= random.RandSlv(Size => ADDRESS_WIDTH);
                rad2 <= random.RandSlv(Size => ADDRESS_WIDTH);
                din <= random.RandSlv(Size => DATA_WIDTH);

                wait_clk_cycles(1);

                calculated_expected;
                check_outputs(expected_collision, expected_dout1, expected_dout2, msg => " at iteration " & to_string(i));
            end loop;

            info(
                "Coverage percentage: " & to_string(coverage_model.GetCov, "%.2f") & " %" &
                " (bins covered: " & to_string(coverage_model.GetTotalCovCount) & "/" & to_string(coverage_model.GetNumBins) & ")" & LF
            );
            info("Coverage details:" & LF);
            coverage_model.WriteBin;

            info(LF & "test_random_inputs completed successfully!" & LF);
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_no_operation") then
                test_no_operation;
            elsif run("test_write_and_read_conflicts") then
                test_write_and_read_conflicts;
            elsif run("test_read_conflict") then
                test_read_conflict;
            elsif run("test_random_inputs") then
                test_random_inputs;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    two_read_one_write_register_file_inst : entity work.two_read_one_write_register_file
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDRESS_WIDTH => ADDRESS_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            wad1 => wad1,
            rad1 => rad1,
            rad2 => rad2,
            wen1 => wen1,
            ren1 => ren1,
            ren2 => ren2,
            dout1 => dout1,
            dout2 => dout2,
            collision => collision
        );
end architecture;
