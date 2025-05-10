--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 12
--!  @details    VHDL module for Trailing Zeroes
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
use work.util_pkg.all;

entity tb_trailing_zeroes is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_trailing_zeroes is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: integer := 8;

    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal dout: unsigned(to_bits(DATA_WIDTH) downto 0) := (others => '0');

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_trailing_zeroes");

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
        -- To see in the waveform
        variable expected_count: unsigned(dout'range);

        function get_expected_trailing_zeroes(data: std_ulogic_vector) return unsigned is
            constant MAX_VALUE_IN_BITS: integer := to_bits(data'length) + 1;
            variable count: unsigned(MAX_VALUE_IN_BITS - 1 downto 0) := (others => '0');
            -- +1 for the maximum amount of trailing zeroes
            variable temp: unsigned(data'range) := unsigned(data);
        begin
            if temp = 0 then
                return to_unsigned(data'length, dout'length);
            end if;

            while temp /= 0 loop
                if temp(0) = '0' then
                    count := count + 1;
                    temp := shift_right(temp, 1); -- Shift right by 1 bit
                else
                    exit;
                end if;
            end loop;
        
            return count;
        end function;

        procedure test_example_1 is
            type test_vector_t is record
                din_val: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
                expected: unsigned(DATA_WIDTH - 1 downto 0);
            end record;

            type test_data_array_t is array(natural range <>) of test_vector_t;

            constant TEST_DATA: test_data_array_t := (
                (din_val => x"50", expected => to_unsigned(4, DATA_WIDTH)), -- 0b01010000
                (din_val => x"00", expected => to_unsigned(8, DATA_WIDTH))  -- 0b00000000
            );
        begin
            info("1.0) test_example_1 - Count trailing zeros");

            for i in TEST_DATA'range loop
                din <= TEST_DATA(i).din_val;
                wait for PROPAGATION_TIME;
                check_equal(got => dout, expected => TEST_DATA(i).expected, msg => "Trailing zero count failed");
            end loop;
        end procedure;

        procedure test_all_zeroes is begin
            info("2.0) test_all_zeroes");

            din <= (others => '0');
            wait for PROPAGATION_TIME;
            expected_count := to_unsigned(din'length, dout'length);
            check_equal(got => dout, expected => expected_count, msg => "Test case 1 failed: All zeros");
        end procedure;

        procedure test_all_ones is begin
            info("3.0) test_all_ones");

            din <= (others => '1');
            wait for PROPAGATION_TIME;
            expected_count := to_unsigned(0, dout'length);
            check_equal(got => dout, expected => expected_count, msg => "Test case 2 failed: All ones");
        end procedure;

        procedure test_random_values is begin
            info("4.0) test_random_values");

            for i in 1 to 1000 loop
                din <= random.RandSlv(Size => din'length);
                wait for PROPAGATION_TIME;
                expected_count := get_expected_trailing_zeroes(data => din);
                check_equal(got => dout, expected => expected_count, msg => "Test case 3 failed: Random value " & to_bstring(din));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);
        
        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_all_zeroes") then
                test_all_zeroes;
            elsif run("test_all_ones") then
                test_all_ones;
            elsif run("test_random_values") then
                test_random_values;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    trailing_zeroes_inst : entity work.trailing_zeroes
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            din => din,
            dout => dout
        );
end architecture;
