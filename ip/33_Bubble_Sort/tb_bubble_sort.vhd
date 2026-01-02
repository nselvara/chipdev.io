--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 33
--!  @details    VHDL module for Bubble Sort
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

entity tb_bubble_sort is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_bubble_sort is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant BITWIDTH: positive := 3;
    constant VECTOR_SIZE: positive := 8;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal simulation_done: boolean := false;

    -- DuT signals
    signal din: std_ulogic_vector(BITWIDTH - 1 downto 0) := (others => '0');
    signal sortit: std_ulogic := '0';
    signal dout: std_ulogic_vector(VECTOR_SIZE * BITWIDTH downto 0);
begin
    generate_clock(clk => clk, FREQ => real(1 sec / CLK_PERIOD));

    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_bubble_sort");

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

        type memory_array_t is array (0 to VECTOR_SIZE - 1) of din'subtype;
        variable expected_sorted: memory_array_t;
        variable expected_output: std_ulogic_vector(VECTOR_SIZE * BITWIDTH downto 0);
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
            sortit <= '0';
            din <= (others => '0');
            wait_clk_cycles(1);
        end procedure;

        procedure start_module is begin
            rst_n <= '1';
            wait_clk_cycles(1);
        end procedure;

        function selection_sort(input_array: memory_array_t) return memory_array_t is
            variable sorted: memory_array_t := input_array;
            variable min_idx: natural;
            variable tmp: std_ulogic_vector(BITWIDTH - 1 downto 0);
        begin
            for i in 0 to VECTOR_SIZE - 2 loop
                min_idx := i;
                for j in i + 1 to VECTOR_SIZE - 1 loop
                    if unsigned(sorted(j)) < unsigned(sorted(min_idx)) then
                        min_idx := j;
                    end if;
                end loop;
                if min_idx /= i then
                    tmp := sorted(i);
                    sorted(i) := sorted(min_idx);
                    sorted(min_idx) := tmp;
                end if;
            end loop;
            return sorted;
        end function;

        function array_to_vector(input_array: memory_array_t) return std_ulogic_vector is
            variable result: std_ulogic_vector(VECTOR_SIZE * BITWIDTH downto 0) := (others => '0');
        begin
            -- Map the MSB to the lowest index
            for idx in 0 to VECTOR_SIZE - 1 loop
                debug("Mapping " & to_string(input_array(VECTOR_SIZE - 1 - idx)) & "(" & to_integer_string(input_array(VECTOR_SIZE - 1 - idx)) & ")");
                result((idx + 1) * BITWIDTH - 1 downto idx * BITWIDTH) := input_array(VECTOR_SIZE - 1 - idx);
            end loop;
            return result;
        end function;

        procedure test_example_1 is
            type expected_array_t is array (0 to VECTOR_SIZE - 1) of dout'subtype;
            constant DIN_SEQUENCE: memory_array_t := (
                "010", "011", "001", "100", "101", "111", "100", "001"
            );
            constant SORTIT_SEQUENCE: std_ulogic_vector(0 to VECTOR_SIZE - 1) := "00011111";
            constant EXPECTED_DOUT_SEQUENCE: expected_array_t := (
                0 to 2 => (others => '0'),
                others => std_ulogic_vector(to_unsigned(16#53#, dout'length))
            );
        begin
            info("1.0) test_example_1" & LF);
            reset_module;
            start_module;

            for i in 0 to VECTOR_SIZE - 1 loop
                din <= DIN_SEQUENCE(i);
                sortit <= SORTIT_SEQUENCE(i);
                wait_clk_cycles(1);
                check_equal(got => dout, expected => EXPECTED_DOUT_SEQUENCE(i), msg => "dout at cycle " & to_string(i));
            end loop;

            info("test_example_1 passed!" & LF);
        end procedure;

        procedure test_wrap_around is
            variable DIN_SEQUENCE: memory_array_t;
        begin
            info("2.0) test_wrap_around" & LF);
            reset_module;
            start_module;

            sortit <= '0';
            for i in 0 to VECTOR_SIZE - 1 loop
                DIN_SEQUENCE(i) := random.RandSlv(Size => BITWIDTH);
                din <= DIN_SEQUENCE(i);
                wait_clk_cycles(1);
            end loop;

            sortit <= '1';
            wait_clk_cycles(1);

            expected_sorted := selection_sort(input_array => DIN_SEQUENCE);
            expected_output := array_to_vector(input_array => expected_sorted);

            check_equal(got => dout, expected => expected_output, msg => "Output should match expected sorted values (wrap around)");

            info("test_wrap_around passed!" & LF);
        end procedure;

        procedure test_zeroes is begin
            info("3.0) test_zeroes" & LF);
            reset_module;
            start_module;

            sortit <= '0';
            for i in 0 to VECTOR_SIZE - 1 loop
                din <= (others => '0');
                wait_clk_cycles(1);
            end loop;

            sortit <= '1';
            wait_clk_cycles(1);

            expected_sorted := selection_sort(input_array => (others => (others => '0')));
            expected_output := array_to_vector(input_array => expected_sorted);

            check_equal(got => dout, expected => expected_output, msg => "Output should match expected sorted values (all zeroes)");

            info("test_zeroes passed!" & LF);
        end procedure;

        procedure test_ones is begin
            info("4.0) test_ones" & LF);
            reset_module;
            start_module;

            sortit <= '0';
            for i in 0 to VECTOR_SIZE - 1 loop
                din <= (others => '1');
                wait_clk_cycles(1);
            end loop;

            sortit <= '1';
            wait_clk_cycles(1);

            expected_sorted := selection_sort(input_array => (others => (others => '1')));
            expected_output := array_to_vector(input_array => expected_sorted);

            check_equal(got => dout, expected => expected_output, msg => "Output should match expected sorted values (all ones)");

            info("test_ones passed!" & LF);
        end procedure;

        procedure test_random is
            variable memory_model: memory_array_t;
            variable write_ptr: natural := 0;
            constant TOTAL_ITERATIONS: positive := 1000;
            constant SORTIT_WEIGHT: NaturalVSlType(std_ulogic'('0') to '1') := ('0' => 80, '1' => 20);
        begin
            info("5.0) test_random" & LF);

            coverage_model.SetName("Random Test Coverage Model");

            coverage_model.AddBins(Name => "rst_n", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "sortit", CovBin => GenBin(Min => 0, Max => 1, NumBin => 1));
            coverage_model.AddBins(Name => "din", CovBin => GenBin(Min => 0, Max => 2**BITWIDTH - 1, NumBin => 8));
            coverage_model.AddBins(Name => "dout", CovBin => GenBin(Min => 0, Max => 2**(VECTOR_SIZE * BITWIDTH) - 1, NumBin => 16));

            rst_n <= '0';
            sortit <= '0';
            din <= (others => '0');
            memory_model := (others => (others => '0'));
            write_ptr := 0;
            wait_clk_cycles(1);

            for iteration in 1 to TOTAL_ITERATIONS loop
                rst_n <= random.DistSl(weight => RESET_N_WEIGHT);
                sortit <= random.DistSl(weight => SORTIT_WEIGHT);
                din <= random.RandSlv(BITWIDTH);

                wait_clk_cycles(1);

                -- Update coverage
                coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & rst_n)));
                coverage_model.ICover(CovPoint => to_integer(unsigned'('0' & sortit)));
                coverage_model.ICover(CovPoint => to_integer(unsigned(din)));

                if rst_n = '0' then
                    memory_model := (others => (others => '0'));
                    write_ptr := 0;
                    expected_output := (others => '0');
                elsif not sortit then
                    memory_model(write_ptr) := din;
                    write_ptr := (write_ptr + 1) mod VECTOR_SIZE;
                else
                    expected_sorted := selection_sort(input_array => memory_model);
                    memory_model := expected_sorted;
                    expected_output := array_to_vector(input_array => expected_sorted);
                    coverage_model.ICover(CovPoint => to_integer(unsigned(dout)));
                end if;

                check_equal(got => dout, expected => expected_output, msg => "dout at iteration " & to_string(iteration));
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
            elsif run("test_wrap_around") then
                test_wrap_around;
            elsif run("test_zeroes") then
                test_zeroes;
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

    DuT: entity work.bubble_sort
        generic map (
            BITWIDTH => BITWIDTH,
            VECTOR_SIZE => VECTOR_SIZE
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            sortit => sortit,
            dout => dout
        );
end architecture;
