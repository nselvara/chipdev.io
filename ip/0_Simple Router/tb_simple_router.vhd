--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 1
--!  @details    VHDL module for Simple Router
--! ----------------------------------------------------------------------------

-- vunit: run_all_in_same_sim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.RandomPType;

entity tb_simple_router is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_simple_router is
    constant SIM_TIMEOUT: time := 10 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: natural := 8;

    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal din_en: std_ulogic := '0';
    signal addr: std_ulogic_vector(1 downto 0) := (others => '0');
    signal dout0: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal dout1: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal dout2: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal dout3: std_ulogic_vector(DATA_WIDTH - 1 downto 0);

    signal simulation_done: boolean := false;
begin
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_simple_router");

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

        procedure check_data(addr: std_ulogic_vector) is
            variable expected_dout0: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
            variable expected_dout1: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
            variable expected_dout2: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
            variable expected_dout3: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0'); 
        begin
            if din_en then
                -- when-else is much compacter but we use the style already in DuT,
                -- thus, a different one is used here so we can see the difference
                if addr = "00" then
                    expected_dout0 := din;
                elsif addr = "01" then
                    expected_dout1 := din;
                elsif addr = "10" then
                    expected_dout2 := din;
                elsif addr = "11" then
                    expected_dout3 := din;
                else
                    check_true(expr => false, msg => "Invalid address: " & to_string(addr));
                end if;
            end if;

            check_equal(got => dout0, expected => expected_dout0, msg => "dout0 should be zero for addr = " & to_string(addr));
            check_equal(got => dout1, expected => expected_dout1, msg => "dout1 should be zero for addr = " & to_string(addr));
            check_equal(got => dout2, expected => expected_dout2, msg => "dout2 should be zero for addr = " & to_string(addr));
            check_equal(got => dout3, expected => expected_dout3, msg => "dout3 should be zero for addr = " & to_string(addr));
        end procedure;

        procedure test_routing is
            variable random_value: unsigned(din'range);
        begin
            info("1.0) test_routing");

            for i in 0 to 2**addr'length - 1 loop
                random_value := random.RandUnsigned(Size => din'length);
                addr <= std_ulogic_vector(to_unsigned(i, addr'length));
                din <= std_ulogic_vector(random_value);

                for polarity in std_ulogic'('1') downto '0' loop
                    din_en <= polarity;
                    wait for PROPAGATION_TIME;
                    check_data(addr);
                end loop;
            end loop;
        end procedure;

        procedure test_random is
            variable random_value: unsigned(din'range);
            variable random_addr: unsigned(addr'range);
        begin
            info("1.0) test_routing");

            for i in 1 to 1000 loop
                random_value := random.RandUnsigned(Size => din'length);
                random_addr := random.RandUnsigned(Size => addr'length);
                addr <= std_ulogic_vector(random_addr);
                din <= std_ulogic_vector(random_value);

                for polarity in std_ulogic'('1') downto '0' loop
                    din_en <= polarity;
                    wait for PROPAGATION_TIME;
                    check_data(addr);
                end loop;
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this line as VUnit will assert error.
        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_routing") then
                test_routing;
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    simple_router_inst: entity work.simple_router
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            din => din,
            din_en => din_en,
            addr => addr,
            dout0 => dout0,
            dout1 => dout1,
            dout2 => dout2,
            dout3 => dout3
        );
end architecture;
