--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 6
--!  @details    VHDL module for Edge Detector
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

entity tb_edge_detector is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_edge_detector is
    constant SIM_TIMEOUT: time := 10 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    signal clk: std_ulogic := '0';
    signal rst_n: std_ulogic := '0';
    signal din: std_ulogic := '0';
    signal dout: std_ulogic := '0';

    signal din_reg: std_ulogic := '0';
    signal expected_dout: std_ulogic := '0';

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
        info("Starting tb_edge_detector");

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;
    ------------------------------------------------------------

    pulse_detector: process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                expected_dout <= '0';
                din_reg <= '0';
            else
                din_reg <= din;
                if din /= din_reg and din = '1' then
                    expected_dout <= '1';
                else
                    expected_dout <= '0';
                end if;
            end if;
        end if;
    end process;

    checker: process
        constant PROPAGATION_TIME: time := 1 ns;
        variable random: RandomPType;

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

        procedure test_example_1 is begin
            info("1.0) test_example_1");

            din <= '0';

            reset_module;
            start_module;

            din <= '1';
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '1');
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0');
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0');
        end procedure;

        procedure test_example_2 is begin
            info("2.0) test_example_2");

            din <= '0';

            reset_module;
            start_module;

            din <= '1';
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '1');
            din <= '0';
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0');
            din <= '1';
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '1');
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0');
        end procedure;

        procedure test_example_3 is begin
            info("3.0) test_example_3");

            din <= '0';

            reset_module;
            start_module;

            rst_n <= '0';
            din <= '1';
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0');
            rst_n <= '1';
            din <= '0';
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0');
            wait_clk_cycles(1);
            check_equal(got => dout, expected => '0');
        end procedure;

        procedure test_random is begin
            info("4.0) test_random");

            din <= '0';

            reset_module;
            start_module;

            for i in 1 to 1000 loop
                rst_n <= random.DistSl(Weight => RESET_WEIGHT_SEQUENCE);
                -- RandSl returns also other than '0' and '1'
                din <= random.RandSlv(1)(1);
                wait_clk_cycles(1);
                check_equal(got => dout, expected => expected_dout);
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_example_2") then
                test_example_2;
            elsif run("test_example_3") then
                test_example_3;
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    edge_detector_inst: entity work.edge_detector
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            dout => dout
        );
end architecture;
