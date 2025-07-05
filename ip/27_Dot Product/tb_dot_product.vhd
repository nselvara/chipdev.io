--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 27
--!  @details    VHDL module for Dot Product
--!  @note       Chipdev.io lists this as quest 28
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
use work.utils_pkg.all;

entity tb_dot_product is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_dot_product is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 8;
    constant VECTOR_SIZE: positive := 3;
    constant DOT_PRODUCT_WIDTH: positive := to_bits(VECTOR_SIZE) + 2 * DATA_WIDTH;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal dout: unsigned(DOT_PRODUCT_WIDTH - 1 downto 0);
    signal run_out: std_ulogic;

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
        info("Starting tb_dot_product");

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
        variable expected_dout: unsigned(DOT_PRODUCT_WIDTH - 1 downto 0);

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

        procedure feed_vector(v: integer_vector) is begin
            for i in v'low to v'high loop
                din <= to_unsigned(v(i), din'length);
                wait_clk_cycles(1);
            end loop;
        end procedure;

        procedure check_output(expected: integer) is begin
            if not run_out then
                wait until run_out;
            end if;

            expected_dout := to_unsigned(expected, expected_dout'length);
            check_equal(got => dout, expected => expected_dout, msg => "dout - Dot product result");
        end procedure;

        procedure calculate_and_check_dot_product(a_vector, b_vector: integer_vector) is
            variable dot_product_result: integer := 0;
        begin
            check(expr => a_vector'length = b_vector'length, msg => "Vector lengths must match");

            for i in a_vector'range loop
                dot_product_result := dot_product_result + (a_vector(i) * b_vector(i));
            end loop;

            feed_vector(a_vector);
            feed_vector(b_vector);
            check_output(dot_product_result);
        end procedure;

        procedure test_example_1 is
            constant A_VECTOR_1: integer_vector := (1, 2, 3);
            constant B_VECTOR_1: integer_vector := (4, 5, 6);
            constant EXPECTED_RESULT_1: natural := 32; -- 1*4 + 2*5 + 3*6
            constant A_VECTOR_2: integer_vector := (7, 8, 9);
            constant B_VECTOR_2: integer_vector := (10, 11, 12);
            constant EXPECTED_RESULT_2: natural := 266; -- 7*10 + 8*11 + 9*12
        begin
            info("1.0) test_example_1" & LF);

            reset_module;
            start_module;

            check_equal(got => dout, expected => 0, msg => "dout - Dot product result");

            info("1.1) First test with vectors A = [1, 2, 3] and B = [4, 5, 6]");
            feed_vector(A_VECTOR_1);
            feed_vector(B_VECTOR_1);
            check_output(EXPECTED_RESULT_1);

            info("1.2) Second test with vectors A = [7, 8, 9] and B = [10, 11, 12]");
            feed_vector(A_VECTOR_2);
            feed_vector(B_VECTOR_2);
            check_output(EXPECTED_RESULT_2);
        end procedure;

        procedure test_all_zeroes is
            constant ZERO_VECTOR: integer_vector(0 to VECTOR_SIZE - 1) := (others => 0);
        begin
            info("2.0) test_all_zeroes - Test with all zeros data" & LF);

            reset_module;
            start_module;

            calculate_and_check_dot_product(ZERO_VECTOR, ZERO_VECTOR);
        end procedure;

        procedure test_all_ones is
            constant ONE_VECTOR: integer_vector(0 to VECTOR_SIZE - 1) := (others => 1);
        begin
            info("3.0) test_all_ones - Test with all ones data" & LF);

            reset_module;
            start_module;

            calculate_and_check_dot_product(ONE_VECTOR, ONE_VECTOR);
        end procedure;

        procedure test_random_data is
            variable a_vector, b_vector: integer_vector(0 to VECTOR_SIZE - 1);
            variable dot_product_result: integer;
            constant MAX_VALUE: integer := 2**(DATA_WIDTH - 1) - 1; -- To avoid overflow
        begin
            info("4.0) test_random_data - Test with random data" & LF);

            for test_case in 1 to 10 loop
                reset_module;
                start_module;

                dot_product_result := 0;
                for i in a_vector'range loop
                    a_vector(i) := random.RandInt(0, MAX_VALUE);
                    b_vector(i) := random.RandInt(0, MAX_VALUE);
                    dot_product_result := dot_product_result + (a_vector(i) * b_vector(i));
                end loop;

                info(
                    "4." & to_string(test_case) & ") Testing random vectors" & LF &
                    "A: " & to_string(a_vector) & LF &
                    "B: " & to_string(b_vector) & LF &
                    "Expected dot product: " & to_string(dot_product_result) & LF
                );

                -- Feed vectors and check result
                feed_vector(a_vector);
                feed_vector(b_vector);
                check_output(dot_product_result);
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_all_zeroes") then
                test_all_zeroes;
            elsif run("test_all_ones") then
                test_all_ones;
            elsif run("test_random_data") then
                test_random_data;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    dot_product_inst: entity work.dot_product
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            VECTOR_SIZE => VECTOR_SIZE
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            dout => dout,
            run_out => run_out
        );
end architecture;
