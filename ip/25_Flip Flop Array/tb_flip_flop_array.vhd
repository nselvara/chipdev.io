--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 25
--!  @details    VHDL module for Flip Flop Array
--! ----------------------------------------------------------------------------

-- vunit: run_all_in_same_sim

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.RandomPType;
use osvvm.NamePkg.NamePType;

use work.tb_utils.all;

entity tb_flip_flop_array is
    generic (
        runner_cfg: string := runner_cfg_default
    );
end entity;

architecture tb of tb_flip_flop_array is
    constant SIM_TIMEOUT: time := 1 ms;
    constant CLK_PERIOD: time := 10 ns;
    constant SYS_RESET_TIME: time := 3 * CLK_PERIOD;
    constant ENABLE_DEBUG_PRINT: boolean := false;

    constant DATA_WIDTH: positive := 8;
    constant ADDRESS_WIDTH: positive := 8;

    signal clk: std_ulogic;
    signal rst_n: std_ulogic;
    signal din: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal addr: unsigned(ADDRESS_WIDTH - 1 downto 0);
    signal wr: std_ulogic;
    signal rd: std_ulogic;
    signal dout: din'subtype;
    signal error: std_ulogic;

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
        info("Starting tb_flip_flop_array");

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
        variable expected_dout: dout'subtype;
        variable expected_error: std_ulogic;
        variable expected_dout_array: integer_array_t;

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

        procedure check_values(index: integer := -1) is
            variable message_suffix: NamePType;
            variable index_string: NamePType;
        begin
            if index >= 0 then
                index_string.Set(to_string(index));
            else
                index_string.Set("");
            end if;
            message_suffix.Set(" for given din " & to_integer_string(din) & " at addr " & to_integer_string(addr) & " at index " & to_string(index));
            check_equal(got => dout, expected => expected_dout, msg => "dout" & message_suffix.GetOpt);
            check_equal(got => error, expected => expected_error, msg => "error" & message_suffix.GetOpt);
        end procedure;

        procedure set_and_get_expected_values is begin
            expected_dout := std_ulogic_vector(to_unsigned(
                get(arr => expected_dout_array, idx => to_integer(unsigned(addr))), dout'length)
            );
            expected_error := wr and rd;

            if rst_n = '0' then
                expected_dout := (others => '0');
                expected_error := '0';
            elsif wr then
                set(arr => expected_dout_array, idx => to_integer(unsigned(addr)), value => to_integer(unsigned(din)));
            end if;
        end procedure;

        procedure set_and_check_sequences(
            i: natural;
            rst_n_seq: std_ulogic_vector;
            din_seq: integer_vector;
            addr_seq: integer_vector;
            wr_seq: std_ulogic_vector;
            rd_seq: std_ulogic_vector;
            expected_output_seq: integer_vector;
            expected_error_seq: std_ulogic_vector
        ) is begin
            rst_n <= rst_n_seq(i);
            din <= std_ulogic_vector(to_unsigned(din_seq(i), din'length));
            addr <= to_unsigned(addr_seq(i), addr'length);
            wr <= wr_seq(i);
            rd <= rd_seq(i);
            wait_clk_cycles(1);
            expected_dout := std_ulogic_vector(to_unsigned(expected_output_seq(i), expected_dout'length));
            expected_error := expected_error_seq(i);
            check_values(index => i);
        end procedure;

        procedure test_example_1 is
            constant RST_N_SEQUENCE: std_ulogic_vector := ("011111");
            constant ADDR_SEQUENCE: integer_vector := (
                0 => 16#0#,
                1 => 16#1#,
                2 => 16#2#,
                3 => 16#3#,
                4 => 16#4#,
                5 => 16#4#
            );
            constant DIN_SEQUENCE: integer_vector := (
                0 => 16#e#,
                1 => 16#80#,
                2 => 16#ff#,
                3 => 16#1#,
                4 => 16#c8#,
                5 => 16#c8#
            );
            constant RD_SEQUENCE: std_ulogic_vector := ("000011");
            constant WR_SEQUENCE: std_ulogic_vector := ("011111");
            constant EXPECTED_OUTPUT_SEQUENCE: integer_vector := (RST_N_SEQUENCE'range => 16#0#);
            constant EXPECTED_ERROR_SEQUENCE: std_ulogic_vector := ("000011");
        begin
            info("1.0) test_example_1");

            for i in DIN_SEQUENCE'low to DIN_SEQUENCE'high loop
                set_and_check_sequences(
                    i,
                    rst_n_seq => RST_N_SEQUENCE,
                    din_seq => DIN_SEQUENCE,
                    addr_seq => ADDR_SEQUENCE,
                    wr_seq => WR_SEQUENCE,
                    rd_seq => RD_SEQUENCE,
                    expected_output_seq => EXPECTED_OUTPUT_SEQUENCE,
                    expected_error_seq => EXPECTED_ERROR_SEQUENCE
                );
            end loop;
        end procedure;

        procedure test_all_combinations is
            constant RST_N_SEQUENCE: std_ulogic_vector := (0 => '0', 1 to 20 => '1');
            constant ADDR_SEQUENCE: integer_vector := (
                0 => 0,     -- Reset
                1 => 0,     -- Write to address 0
                2 => 1,     -- Write to address 1
                3 => 0,     -- Read from address 0
                4 => 1,     -- Read from address 1
                5 => 2,     -- Write to address 2
                6 => 3,     -- Write to address 3
                7 => 2,     -- Read from address 2
                8 => 3,     -- Write + Read to same address
                9 => 4,     -- Write to address 4
                10 => 4,    -- Read back from address 4
                11 => 0,    -- Write again to address 0
                12 => 1,    -- Read from address 1 (shouldn't change)
                13 => 0,    -- Read from address 0 (should be changed)
                14 => 7,    -- 
                15 => 7,    -- 
                16 => 255,  -- 
                17 => 255,  -- 
                18 => 10,   -- 
                19 => 10,   -- 
                20 => 0     -- 
            );
            constant DIN_SEQUENCE: integer_vector := (
                0 => 16#00#,    -- Reset
                1 => 16#A5#,    -- Data for address 0
                2 => 16#5A#,    -- Data for address 1
                3 => 16#00#,    -- Not used for read
                4 => 16#00#,    -- Not used for read
                5 => 16#F0#,    -- Data for address 2
                6 => 16#0F#,    -- Data for address 3
                7 => 16#00#,    -- Not used for read
                8 => 16#21#,    -- Data for address 3 (Error case)
                9 => 16#33#,    -- Data for address 4
                10 => 16#00#,   -- Not used for read
                11 => 16#CC#,   -- New data for address 0
                12 => 16#00#,   -- Not used for read
                13 => 16#00#,   -- Not used for read
                14 => 16#77#,   -- Data for address 7
                15 => 16#00#,   -- Not used for read
                16 => 16#FF#,   -- Data for address 255
                17 => 16#00#,   -- Not used for read
                18 => 16#AA#,   -- Nothing
                19 => 16#00#,   -- Data for address 10
                20 => 16#00#    -- Nothing
            );
            constant WR_SEQUENCE: std_ulogic_vector := "011001101101001010010";
            constant RD_SEQUENCE: std_ulogic_vector := "000110011010010101000";

            constant EXPECTED_OUTPUT_SEQUENCE: integer_vector := (
                0 => 16#00#,    -- Reset
                1 => 16#00#,    -- Not reading
                2 => 16#00#,    -- Not reading
                3 => 16#A5#,    -- Read from address 0
                4 => 16#5A#,    -- Read from address 1
                5 => 16#5A#,    -- Not reading, output is unchanged
                6 => 16#5A#,    -- Not reading, output is unchanged
                7 => 16#F0#,    -- Read from address 2
                8 => 16#00#,    -- Error (read & write), output is 0
                9 => 16#00#,    -- Not reading, output is unchanged
                10 => 16#33#,   -- Read from address 4 (Never written)
                11 => 16#33#,   -- Not reading, output is unchanged
                12 => 16#33#,   -- Nothing, output is unchanged
                13 => 16#CC#,   -- Not reading, output is unchanged
                14 => 16#CC#,   -- Not reading, output is unchanged
                15 => 16#77#,   -- Read from address 7
                16 => 16#77#,   -- Not reading, output is unchanged
                17 => 16#FF#,   -- Read from address 255 (Never written)
                18 => 16#FF#,   -- Not reading, output is unchanged
                19 => 16#FF#,   -- Read from address 10 (Never written)
                20 => 16#FF#    -- Not reading, output is unchanged
            );
            constant EXPECTED_ERROR_SEQUENCE: std_ulogic_vector := "000000001000000000000";
        begin
            info("2.0) test_all_combinations");

            -- Initialize expected output array
            expected_dout_array := new_1d(length => 2**ADDRESS_WIDTH, bit_width => DATA_WIDTH, is_signed => false);

            for i in ADDR_SEQUENCE'low to ADDR_SEQUENCE'high loop
                set_and_check_sequences(
                    i,
                    rst_n_seq => RST_N_SEQUENCE,
                    din_seq => DIN_SEQUENCE,
                    addr_seq => ADDR_SEQUENCE,
                    wr_seq => WR_SEQUENCE,
                    rd_seq => RD_SEQUENCE,
                    expected_output_seq => EXPECTED_OUTPUT_SEQUENCE,
                    expected_error_seq => EXPECTED_ERROR_SEQUENCE
                );
            end loop;
        end procedure;

        procedure test_random_values is begin
            info("3.0) test_random_values");

            expected_dout_array := new_1d(length => 2**ADDRESS_WIDTH, bit_width => DATA_WIDTH, is_signed => false);

            for i in 1 to 1000 loop
                rst_n <= random.DistSl(Weight => RESET_N_WEIGHT);
                din <= random.RandSlv(Size => din'length);
                addr <= random.RandUnsigned(Size => addr'length);
                wr <= random.RandSlv(1)(1);
                rd <= random.RandSlv(1)(1);
                wait_clk_cycles(1);
                set_and_get_expected_values;
            end loop;
        end procedure;
    begin
        random.InitSeed(random'instance_name);
        
        wait_clk_cycles(1);

        while test_suite loop
            if run("test_example_1") then
                test_example_1;
            elsif run("test_all_combinations") then
                test_all_combinations;
            elsif run("test_random_values") then
                test_random_values;
            else
                assert false report "No test has been run!" severity failure;
            end if;
        end loop;

        simulation_done <= true;
        wait;
    end process;

    flip_flop_array_inst: entity work.flip_flop_array
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDRESS_WIDTH => ADDRESS_WIDTH
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            din => din,
            addr => addr,
            wr => wr,
            rd => rd,
            dout => dout,
            error => error
        );
end architecture;
