--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 5
--!  @details    VHDL module for Bit Reverser
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

entity tb_bit_reverser is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_bit_reverser is
    constant SIM_TIMEOUT: time := 10 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: integer := 32;

    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal dout: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_bit_reverser");

        if ENABLE_DEBUG_PRINT then
            show(display_handler, debug);
        end if;

        wait until simulation_done;
        log("Simulation done, all tests passed!");
        test_runner_cleanup(runner);
        wait;
    end process;
    ------------------------------------------------------------

    checker: process
        variable random: RandomPType;

        function reverse_bits(input: std_ulogic_vector) return std_ulogic_vector is
            variable reversed: input'subtype;
        begin
            for i in input'range loop
                reversed(i) := input(input'high - i);
            end loop;
            return reversed;
        end function;

        procedure check_values is begin
            check_equal(got => dout, expected => reverse_bits(input => din), msg => "Bit Reverser");
        end procedure;

        -- Testing all combinations would take way too long, so we will just test a few random values
        procedure test_bit_reverser_randomly is begin
            info("1.0) test_bit_reverser_randomly");

            for i in 1 to 1000 loop
                din <= random.RandSlv(Size => din'length);
                wait for PROPAGATION_TIME;
                check_values;
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_bit_reverser_randomly") then
                test_bit_reverser_randomly;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    bit_reverser_inst: entity work.bit_reverser
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            din => din,
            dout => dout
        );
end architecture;
