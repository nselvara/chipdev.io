--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 13
--!  @details    VHDL module for One-Hot Detector
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

entity tb_one_hot_detector is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_one_hot_detector is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 8;

    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal one_hot: std_ulogic;

    signal simulation_done: boolean := false;
begin
    ------------------------------------------------------------
    -- VUnit
    ------------------------------------------------------------
    test_runner_watchdog(runner, SIM_TIMEOUT);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        info("Starting tb_one-hot_detector");

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
        variable expected_onehot: std_ulogic;

        function get_expected_one_hot(data: in std_ulogic_vector) return std_ulogic is
            variable count: natural := 0;
        begin
            for i in data'range loop
                if data(i) then
                    count := count + 1;
                end if;
            end loop;

            if count = 1 then
                return '1';
            else
                return '0';
            end if;
        end function;

        function create_integer_weight(percentage: natural range 0 to 100; length: positive) return integer_vector is
            constant TOTAL_AMOUNT: integer := 2**length;
            constant PERCENTAGE_FOR_EACH_ONE: real := real(percentage) / real(length);
            variable result: integer_vector(TOTAL_AMOUNT - 1 downto 0) := (others => 0);
        begin
            for i in result'range loop
                for j in 0 to length - 1 loop
                    -- Check each bit position
                    -- Multiply by 100 to not have rounding errors
                    if i = 2**j then
                        result(i) := integer(PERCENTAGE_FOR_EACH_ONE * 100.0);
                    else
                        result(i) := integer((100.0 - PERCENTAGE_FOR_EACH_ONE) * 100.0);
                    end if;
                end loop;
            end loop;

            return result;
        end function;

        procedure test_all_zeroes is begin
            info("1.0) test_all_zeroes");

            din <= (others => '0');
            wait for PROPAGATION_TIME;
            expected_onehot := '0';
            check_equal(got => one_hot, expected => expected_onehot, msg => "Test case 1 failed: All zeros");
        end procedure;

        procedure test_all_ones is begin
            info("2.0) test_all_ones");

            din <= (others => '1');
            wait for PROPAGATION_TIME;
            expected_onehot := '0';
            check_equal(got => one_hot, expected => expected_onehot, msg => "Test case 2 failed: All ones");
        end procedure;

        procedure test_all_possible_one_hot is begin
            info("3.0) test_all_possible_one_hot");

            expected_onehot := '1';

            for i in din'range loop
                din <= (others => '0');
                din(i) <= '1';
                wait for PROPAGATION_TIME;
                check_equal(got => one_hot, expected => expected_onehot, msg => "Test case 3 failed: One-hot value " & to_bstring(din));
            end loop;
        end procedure;

        procedure test_random_values is
            constant WEIGHT_ONEHOT: integer_vector := create_integer_weight(percentage => 20, length => din'length);
        begin
            info("4.0) test_random_values");

            for i in 1 to 1000 loop
                din <= random.DistSlv(Size => din'length, weight => WEIGHT_ONEHOT);
                wait for PROPAGATION_TIME;
                expected_onehot := get_expected_one_hot(data => din);
                check_equal(got => one_hot, expected => expected_onehot, msg => "Test case 3 failed: Random value " & to_bstring(din));
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);
        
        wait for PROPAGATION_TIME;

        while test_suite loop
            if run("test_all_zeroes") then
                test_all_zeroes;
            elsif run("test_all_ones") then
                test_all_ones;
            elsif run("test_all_possible_one_hot") then
                test_all_possible_one_hot;
            elsif run("test_random_values") then
                test_random_values;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    one_hot_detector_inst : entity work.one_hot_detector
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            din => din,
            one_hot => one_hot
        );
end architecture;
