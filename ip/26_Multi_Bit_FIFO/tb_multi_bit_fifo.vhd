--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 26
--!  @details    VHDL module for Multi Bit FIFO
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

entity tb_multi_bit_fifo is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_multi_bit_fifo is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 8;
    constant FIFO_DEPTH: positive := 2;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal wr: std_ulogic := '0';
    signal dout: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal full: std_ulogic;
    signal empty: std_ulogic;

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
        info("Starting tb_multi_bit_fifo");

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
        variable random_data: din'subtype;
        variable expected_value: dout'subtype;

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

        procedure write_data(data: std_ulogic_vector) is begin
            wr <= '1';
            din <= data;
            wait_clk_cycles(1);
            wr <= '0';
            wait_clk_cycles(1);
        end procedure;

        procedure check_flags(expected_full, expected_empty: std_ulogic) is begin
            check_equal(got => full, expected => expected_full, msg => "full flag check");
            check_equal(got => empty, expected => expected_empty, msg => "empty flag check");
        end procedure;

        procedure check_output(expected: dout'subtype) is begin
            check_equal(got => dout, expected => expected, msg => "dout check");
        end procedure;

        procedure test_example_1 is
            constant TEST_DATA1: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"55";
            constant TEST_DATA2: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"AA";
        begin
            info("1.0) test_example_1 - Basic FIFO operation");

            reset_module;
            start_module;

            -- Check empty condition
            check_flags(expected_full => '0', expected_empty => '1');
            check_output(expected => (others => '0'));

            -- Write first value
            write_data(data => TEST_DATA1);
            check_flags(expected_full => '0', expected_empty => '0');
            check_output(expected => TEST_DATA1);

            -- Write second value
            write_data(data => TEST_DATA2);
            check_flags(expected_full => '1', expected_empty => '0');
            check_output(expected => TEST_DATA1);

            -- Overflow
            write_data(data => X"33");
            check_flags(expected_full => '1', expected_empty => '0');
        end procedure;

        procedure test_reset is begin
            info("2.0) test_reset - Verify initial state after reset");

            reset_module;
            check_flags(expected_full => '0', expected_empty => '1');
            check_output(expected => (others => '0'));

            start_module;
            check_flags(expected_full => '0', expected_empty => '1');
            check_output(expected => (others => '0'));
        end procedure;

        procedure test_single_write is
            constant TEST_DATA: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"A5";
        begin
            info("3.0) test_single_write - Single write and read");

            reset_module;
            start_module;

            -- Initially empty
            check_flags(expected_full => '0', expected_empty => '1');

            write_data(data => TEST_DATA);

            -- Should have data and not be empty
            check_flags(expected_full => '0', expected_empty => '0');
            check_output(expected => TEST_DATA);
        end procedure;

        procedure test_fill_fifo is
            constant TEST_DATA1: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"A5";
            constant TEST_DATA2: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"5A";
        begin
            info("4.0) test_fill_fifo - Fill FIFO and verify full condition");

            reset_module;
            start_module;

            -- Write first data
            write_data(data => TEST_DATA1);
            check_flags(expected_full => '0', expected_empty => '0');
            check_output(expected => TEST_DATA1);

            -- Write second data
            write_data(data => TEST_DATA2);
            check_flags(expected_full => '1', expected_empty => '0');
            -- In this FIFO implementation, the oldest data is at the highest index
            check_output(expected => TEST_DATA1);
        end procedure;

        procedure test_overflow is
            constant TEST_DATA1: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"A5";
            constant TEST_DATA2: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"5A";
            constant TEST_DATA3: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"FF";
            constant TEST_DATA4: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"00";
        begin
            info("5.0) test_overflow - Test behavior when writing to full FIFO");

            reset_module;
            start_module;

            -- Fill FIFO
            write_data(data => TEST_DATA1);
            check_flags(expected_full => '0', expected_empty => '0');
            check_output(expected => TEST_DATA1);
            write_data(data => TEST_DATA2);
            check_flags(expected_full => '1', expected_empty => '0');
            -- If we're in full state, output won't be immediately updated
            -- Only after the next write
            check_output(expected => TEST_DATA1);

            -- Write another value (overflow)
            write_data(data => TEST_DATA3);
            check_flags(expected_full => '1', expected_empty => '0');
            check_output(expected => TEST_DATA2);

            -- Still full, should not change output
            for i in 1 to 20 loop
                wait_clk_cycles(1);
                check_flags(expected_full => '1', expected_empty => '0');
                check_output(expected => TEST_DATA2);
            end loop;

            -- Write another value (should still be full)
            write_data(data => TEST_DATA4);
            check_flags(expected_full => '1', expected_empty => '0');
            -- Now output should update to previous value
            check_output(expected => TEST_DATA3);
        end procedure;

        procedure test_multiple_sequences is
            constant TEST_DATA1: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"A5";
            constant TEST_DATA2: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := X"5A";
        begin
            info("6.0) test_multiple_sequences - Multiple write sequences with reset");

            reset_module;
            start_module;

            -- First sequence
            write_data(data => TEST_DATA1);
            check_output(expected => TEST_DATA1);

            -- Reset
            reset_module;
            check_flags(expected_full => '0', expected_empty => '1');

            -- Second sequence
            start_module;
            write_data(data => TEST_DATA2);
            check_output(expected => TEST_DATA2);
        end procedure;

        procedure test_all_zeroes is
            constant TEST_DATA: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        begin
            info("7.0) test_all_zeroes - Test with all zeros data");

            reset_module;
            start_module;

            write_data(data => TEST_DATA);
            check_flags(expected_full => '0', expected_empty => '0');
            check_output(expected => TEST_DATA);
        end procedure;

        procedure test_all_ones is
            constant TEST_DATA: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '1');
        begin
            info("8.0) test_all_ones - Test with all ones data");

            reset_module;
            start_module;

            write_data(data => TEST_DATA);
            check_flags(expected_full => '0', expected_empty => '0');
            check_output(expected => TEST_DATA);
        end procedure;

        procedure test_random_sequences is
            variable expected_queue: queue_t;
            variable write_count: natural := 0;
            variable first_full_detected: boolean := false;
        begin
            info("9.0) test_random_sequences - Random write sequences");

            reset_module;
            start_module;

            write_count := 0;
            expected_queue := new_queue;

            for i in 1 to 100 loop
                if random.RandInt(0, 100) <= 99 then  -- 99% chance to write
                    random_data := random.RandSlv(Size => DATA_WIDTH);
                    push(queue => expected_queue, value => random_data);
                    write_count := (write_count + 1);
                    write_data(data => random_data);
                else  -- 1% chance to reset
                    reset_module;
                    start_module;

                    if expected_queue = null_queue then
                        flush(queue => expected_queue);
                    end if;
                    expected_queue := new_queue;

                    write_count := 0;
                    first_full_detected := false;
                end if;

                if write_count = 0 then
                    check_flags(expected_full => '0', expected_empty => '1');
                    check_output(expected => (others => '0'));
                else
                    if write_count >= FIFO_DEPTH then
                        if first_full_detected then
                            expected_value := pop(queue => expected_queue);
                        end if;
                        first_full_detected := true;
                        check_flags(expected_full => '1', expected_empty => '0');
                    else
                        expected_value := pop(queue => expected_queue);
                        check_flags(expected_full => '0', expected_empty => '0');
                    end if;

                    check_output(expected => expected_value);
                end if;
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_reset") then
                test_reset;
            elsif run("test_single_write") then
                test_single_write;
            elsif run("test_fill_fifo") then
                test_fill_fifo;
            elsif run("test_overflow") then
                test_overflow;
            elsif run("test_multiple_sequences") then
                test_multiple_sequences;
            elsif run("test_all_zeroes") then
                test_all_zeroes;
            elsif run("test_all_ones") then
                test_all_ones;
            elsif run("test_random_sequences") then
                test_random_sequences;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    multi_bit_fifo_inst: entity work.multi_bit_fifo
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            wr => wr,
            dout => dout,
            full => full,
            empty => empty
        );
end architecture;
