--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 11
--!  @details    VHDL module for Gray Code to Binary
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

entity tb_gray_code_to_binary is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_gray_code_to_binary is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant PROPAGATION_TIME: time := 1 ns;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: integer := 8;

    signal din: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal dout: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_gray_code_to_binary");

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

        function gray_to_binary(value: unsigned) return unsigned is
            variable binary: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
        begin
            -- MSB of binary is the same as the MSB of Gray code
            binary(DATA_WIDTH - 1) := value(DATA_WIDTH - 1);

            -- Compute remaining bits
            for i in DATA_WIDTH - 2 downto 0 loop
                if value(i) = '0' then
                    binary(i) := binary(i + 1); -- Copy the previous bit
                else
                    binary(i) := not binary(i + 1); -- Invert the previous bit
                end if;
            end loop;

            return binary;
        end function;

        procedure check_binary_code(expected: unsigned) is begin
            check_equal(got => dout, expected => expected, msg => "dout - Binary code value mismatch!");
        end procedure;

        procedure test_example_1 is
            variable expected_binary_value: dout'subtype := (others => '0');

            type gray_bin_pair_t is record
                gray: unsigned(DATA_WIDTH - 1 downto 0);
                bin: unsigned(DATA_WIDTH - 1 downto 0);
            end record;

            type test_data_t is array(natural range <>) of gray_bin_pair_t;

            constant TEST_DATA: test_data_t := (
                (gray => "00000110", bin => to_unsigned(4, DATA_WIDTH)),
                (gray => "00001110", bin => to_unsigned(11, DATA_WIDTH))
            );
        begin
            info("1.0) test_example_1 - Gray to binary index conversion");

            for i in TEST_DATA'range loop
                din <= TEST_DATA(i).gray;
                wait for PROPAGATION_TIME;
                check_binary_code(expected => TEST_DATA(i).bin);
            end loop;
        end procedure;

        procedure test_binary_code_with_all_possible_combinations is
            variable expected_binary_value: dout'subtype := (others => '0');
        begin
            info("2.0) test_binary_dout_with_expected");

            for i in 0 to 2**dout'length - 1 loop
                din <= to_unsigned(i, din'length);
                wait for PROPAGATION_TIME;
                expected_binary_value := gray_to_binary(value => din);
                debug("din = " & to_string(din) & ", dout = " & to_string(dout) & ", expected = " & to_string(expected_binary_value));
                check_binary_code(expected => expected_binary_value);
            end loop;
        end procedure;

        procedure test_binary_code_randomly is
            variable expected_binary_value: dout'subtype := (others => '0');
        begin
            info("3.0) test_binary_code_randomly");

            for i in 1 to 1000 loop
                -- RandUnsigned returns full range of std_ulogic, thus, convert to '0' or '1'
                din <= To_X01(random.RandUnsigned(Size => din'length));
                wait for PROPAGATION_TIME;
                expected_binary_value := gray_to_binary(value => din);
                debug("din = " & to_string(din) & ", dout = " & to_string(dout) & ", expected = " & to_string(expected_binary_value));
                check_binary_code(expected => expected_binary_value);
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);

        -- NOTE: Don't remove this line as VUnit will assert error.
        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_binary_code_with_all_possible_combinations") then
                test_binary_code_with_all_possible_combinations;
            elsif run("test_binary_code_randomly") then
                test_binary_code_randomly;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    dut_inst : entity work.gray_code_to_binary
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            din  => din,
            dout => dout
        );
end architecture;
