--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 3
--!  @details    VHDL module for Rounding Division
--! ----------------------------------------------------------------------------

-- vunit: run_all_in_same_sim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.RandomPType;

entity tb_rounding_division is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_rounding_division is
    constant SIM_TIMEOUT: time := 10 ms;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DIV_LOG2: natural := 3;
    constant OUT_WIDTH: natural := 2;
    constant IN_WIDTH: natural := OUT_WIDTH + DIV_LOG2;

    signal din: unsigned(IN_WIDTH - 1 downto 0) := (others => '0');
    signal dout: unsigned(OUT_WIDTH - 1 downto 0);

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_rounding_division");

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
        constant PROPAGATION_TIME: time := 1 ns;
        variable random: RandomPType;

        function calculate_quotient(din: unsigned) return unsigned is
            variable quotient: real;
        begin
            quotient := round(real(to_integer(din)) / 2.0**DIV_LOG2);
            return to_unsigned(integer(quotient), dout'subtype'length);
        end function;

        procedure test_examples is
            type unsigned_vector_t is array (natural range <>) of din'subtype;
            constant TEST_CASES: unsigned_vector_t := (to_unsigned(16#B#, din'length), to_unsigned(16#F#, din'length));
        begin
            info("1.0) test_examples");

            for i in TEST_CASES'range loop
                din <= TEST_CASES(i);
                wait for PROPAGATION_TIME;
                check_equal(got => dout, expected => calculate_quotient(TEST_CASES(i)));
            end loop;
        end procedure;

        procedure test_random is begin
            info("2.0) test_random");
            
            for i in 1 to 1000 loop
                din <= random.RandUnsigned(Size => din'length);
                wait for PROPAGATION_TIME;
                check_equal(got => dout, expected => calculate_quotient(din));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_examples") then
                test_examples;
            elsif run("test_random") then
                test_random;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    rounding_division_inst: entity work.rounding_division
        generic map (
            DIV_LOG2 => DIV_LOG2,
            OUT_WIDTH => OUT_WIDTH,
            IN_WIDTH => IN_WIDTH
        )
        port map (
            din => din,
            dout => dout
        );
end architecture;
