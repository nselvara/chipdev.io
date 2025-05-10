--! 
--! @author:    N. Selvarajah
--! @brief:     This package contains testbench utility functions used in the project.
--! @details:   
--!
--! @license    This project is released under the terms of the GNU GENERAL PUBLIC LICENSE v3. See LICENSE.md for more details.
--! 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- for resize
use ieee.math_real.all; -- for ceil and to_bits functions

library osvvm;
use osvvm.RandomPkg.RandomPType;
use osvvm.RandomPkg.NaturalVSlType;

package tb_utils is
    -- Only 1% of the time is reset(_n) active
    constant RESET_N_WEIGHT: NaturalVSlType(std_ulogic'('0') to '1') := ('0' => 1, '1' => 99);
    constant RESET_WEIGHT: NaturalVSlType(std_ulogic'('0') to '1') := ('0' => 99, '1' => 1);
    -- For 50% of the time, the signal is '0' or '1'
    constant WEIGHT_50_PERCENT: NaturalVSlType(std_ulogic'('0') to '1') := ('0' => 50, '1' => 50);

    ------------------------------------------------------------
    -- Procedure for clock generation (less time resolution issues)
    -- usage: generate_clock(sys_clk, 66.67E6); -- 66.67MHz
    ------------------------------------------------------------
    procedure generate_clock(signal clk: out std_ulogic; constant FREQ: real);

    ------------------------------------------------------------
    -- Advanced procedure for clock generation
    -- with period adjust to match frequency over time, and run control by signal
    -- usage: generate_clock_advanced(sys_clk, 66.67E6, 0 fs, clock_run); -- 66.67MHz
    ------------------------------------------------------------
    procedure generate_clock_advanced(signal clk: out std_ulogic; constant FREQ: real; PHASE: time:= 0 fs; signal run: std_ulogic; constant duty_cycle_in_percent: real:= 50.0);
end tb_utils;

package body tb_utils is
    ------------------------------------------------------------
    -- Procedure for clock generation (less time resolution issues)
    -- usage: generate_clock(sys_clk, 66.67E6); -- 66.67MHz
    ------------------------------------------------------------
    procedure generate_clock(signal clk: out std_ulogic; constant FREQ: real) is
        constant PERIOD: time:= 1 sec / FREQ; -- Full period
        constant HIGH_TIME: time:= PERIOD / 2; -- High time
        constant LOW_TIME: time:= PERIOD - HIGH_TIME; -- Low time; always >= HIGH_TIME
    begin
        -- Check the arguments
        assert (HIGH_TIME /= 0 fs) report "generate_clock: High time is zero; time resolution to large for frequency" severity FAILURE;

        loop
            clk <= '1';
            wait for HIGH_TIME;
            clk <= '0';
            wait for LOW_TIME;
        end loop;
    end procedure;
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Advanced procedure for clock generation
    -- with period adjust to match frequency over time, and run control by signal
    ------------------------------------------------------------
    procedure generate_clock_advanced(signal clk: out std_ulogic; FREQ: real; PHASE: time:= 0 fs; signal run: std_ulogic; duty_cycle_in_percent: real:= 50.0) is
        constant HIGH_TIME: time := duty_cycle_in_percent * 0.01 sec / FREQ; -- High time as fixed value
        variable low_time_v: time; -- Low time calculated per cycle; always >= HIGH_TIME
        variable cycles_v: real := 0.0; -- Number of cycles
        variable freq_time_v: time := 0 fs; -- Time used for generation of cycles
    begin
        -- Check the arguments
        assert (HIGH_TIME /= 0 fs) report "generate_clock_advanced: High time is zero; time resolution to large for frequency" severity FAILURE;

        -- Initial phase shift
        clk <= '0';
        wait for PHASE;
        -- Generate cycles
        loop
            if run then
                clk <= run;
            end if;
            wait for HIGH_TIME;

            -- Low part of cycle
            clk <= '0';
            low_time_v := 1 sec * ((cycles_v + 1.0) / FREQ) - freq_time_v - HIGH_TIME; -- + 1.0 for cycle after current
            wait for low_time_v;

            -- Cycle counter and time passed update
            cycles_v := cycles_v + 1.0;
            freq_time_v := freq_time_v + HIGH_TIME + low_time_v;
        end loop;
    end procedure;
    ------------------------------------------------------------
end package body;
