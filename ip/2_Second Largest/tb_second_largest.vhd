--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 2
--!  @details    Testbench for "second_largest" that validates the correct output value
--!              for a clocked input stream based on second-largest seen input so far
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

entity tb_second_largest is
    generic (
        runner_cfg : string := runner_cfg_default
    );
end entity;

architecture tb of tb_second_largest is
    constant DATA_WIDTH: natural := 8;
    constant SIM_TIMEOUT: time := 10 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal dout: unsigned(DATA_WIDTH - 1 downto 0);

    signal simulation_done: boolean := false;
begin
    generate_clock(clk => clk, FREQ => real(1 sec / CLK_PERIOD));

    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_multiwell_event_mode_data_acquisition");

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
    -- Checker
    ------------------------------------------------------------
    checker: process
        type test_data_t is array(natural range <>) of natural;
        variable random: RandomPType;

        procedure wait_clk_cycles(n : positive) is begin
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

        procedure apply(input : in natural) is begin
            din <= to_unsigned(input, DATA_WIDTH);
            wait_clk_cycles(1);
        end procedure;

        procedure test_example_1 is
            constant TEST_DATA_SEQENCE: test_data_t := (16#2#, 16#6#, 16#0#, 16#E#, 16#C#, 16#0#, 16#1#, 16#2#);
            constant EXPECTED_DATA: test_data_t :=     (16#0#, 16#2#, 16#2#, 16#6#, 16#c#, 16#0#, 16#0#, 16#1#);
        begin
            info("1.0) example_1 - x2, x6, x0, xE, xC, x0, x1, x2");

            apply(input => 0);
            reset_module;
            start_module;
        
            for i in TEST_DATA_SEQENCE'range loop
                if i = 5 then -- According to the example, the reset is applied here
                    rst_n <= '0';
                end if;
                debug(to_string(i));
                apply(input => TEST_DATA_SEQENCE(i));
                check_equal(got => dout, expected => EXPECTED_DATA(i), msg => "dout");
                rst_n <= '1';
            end loop;
        end procedure;

        procedure test_reset is begin
            info("2.0) reset");

            apply(input => 0);
            reset_module;
            check_equal(got => dout, expected => to_unsigned(0, DATA_WIDTH), msg => "dout");
            wait_clk_cycles(1);
            check_equal(got => dout, expected => to_unsigned(0, DATA_WIDTH), msg => "dout");
        end procedure;

        procedure test_example_2 is
            constant TEST_DATA_SEQENCE: test_data_t := (16#1#, 16#2#, 16#3#, 16#3#, 16#3#);
            constant EXPECTED_DATA: test_data_t :=     (16#0#, 16#1#, 16#2#, 16#3#, 16#3#);
        begin
            info("3.0) example_2 - x1, x2, x3, x3, x3");

            apply(input => 0);
            reset_module;
            start_module;
        
            for i in TEST_DATA_SEQENCE'range loop
                debug(to_string(i));
                apply(input => TEST_DATA_SEQENCE(i));
                check_equal(got => dout, expected => EXPECTED_DATA(i), msg => "dout");
            end loop;

            apply(input => 0);
        end procedure;

        procedure test_random is
            variable expected_largest_value: din'subtype := to_unsigned(0, din'length);
            variable expected_second_largest_value: din'subtype := to_unsigned(0, din'length);    
            variable random_value: natural;
        begin
            info("4.0) random test - 1000 random numbers");

            apply(input => 0);
            reset_module;
            start_module;

            for i in 1 to 1000 loop
                debug(to_string(i));

                random_value := random.RandInt(Min => 0, Max => 2**DATA_WIDTH - 1);
                rst_n <= random.DistSl(Weight => RESET_N_WEIGHT);
                apply(input => random_value);

                if rst_n = '0' then
                    expected_largest_value := to_unsigned(0, din'length);
                    expected_second_largest_value := to_unsigned(0, din'length);
                elsif din > expected_second_largest_value then
                    expected_second_largest_value := din;
                    if din > expected_largest_value then
                        expected_second_largest_value := expected_largest_value;
                        expected_largest_value := din;
                    end if;
                end if;

                check_equal(got => dout, expected => expected_second_largest_value, msg => "dout");
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this line as VUnit will assert error.
        -- NOTE: Don't remove this, or else VUnit won't be able to run the tests
        wait_clk_cycles(1);

        while test_suite loop
            if run("example_1") then
                test_example_1;
            elsif run("reset") then
                test_reset;
            elsif run("example_2") then
                test_example_2;
            elsif run("random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    DuT: entity work.second_largest
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            dout => dout
        );
end architecture;
