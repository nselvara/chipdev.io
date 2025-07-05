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
    -- Procedure for clock generation with reset control
    -- Clock is forced to '0' during reset (rst_n='0')
    -- usage: generate_clock_with_reset(sys_clk, rst_n, 66.67E6); -- 66.67MHz
    ------------------------------------------------------------
    procedure generate_clock(signal clk: out std_ulogic; signal rst_n: in std_ulogic; constant FREQ: real);

    ------------------------------------------------------------
    -- Procedure for generating a derived clock signal
    -- from an input clock signal with a specified division factor.
    -- usage: generate_derived_clock(clk_in, rst_n, clk_out, 4); -- Divide by 4
    ------------------------------------------------------------
    procedure generate_derived_clock(
        signal clk_in: in std_ulogic; 
        signal rst_n: in std_ulogic; 
        signal clk_out: out std_ulogic; 
        constant factor: in natural
    );

    ------------------------------------------------------------
    -- Advanced procedure for clock generation
    -- with period adjust to match frequency over time, and run control by signal
    -- usage: generate_clock_advanced(sys_clk, 66.67E6, 0 fs, enable, 50.0);
    ------------------------------------------------------------
    procedure generate_clock_advanced(
        signal clk_out: out std_ulogic; 
        constant target_freq: real; 
        constant initial_delay: time := 0 fs; 
        signal enable: std_ulogic;
        constant duty: real := 50.0
    );

    ------------------------------------------------------------
    -- Function to convert an integer vector to a string representation
    -- usage: to_string(input_vector);
    ------------------------------------------------------------
    -- NOTE: There's no way to create a generic function with an array type in VHDL-2008
    impure function to_string(input: integer_vector) return string;
end package;

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
    -- Procedure for clock generation with reset control
    -- Clock is forced to '0' during reset (rst_n='0')
    -- usage: generate_clock_with_reset(sys_clk, rst_n, 66.67E6); -- 66.67MHz
    ------------------------------------------------------------
    procedure generate_clock(signal clk: out std_ulogic; signal rst_n: in std_ulogic; constant FREQ: real) is
        constant PERIOD: time:= 1 sec / FREQ; -- Full period
        constant HIGH_TIME: time:= PERIOD / 2; -- High time
        constant LOW_TIME: time:= PERIOD - HIGH_TIME; -- Low time; always >= HIGH_TIME
    begin
        -- Check the arguments
        assert (HIGH_TIME /= 0 fs) 
            report "generate_clock_with_reset: High time is zero; time resolution too large for frequency" 
            severity FAILURE;

        loop
            if rst_n = '0' then
                -- During reset, force clock to '0'
                clk <= '0';
                wait until rst_n = '1';
            else
                -- Normal clock operation
                clk <= '1';
                wait for HIGH_TIME;
                clk <= '0';
                wait for LOW_TIME;
            end if;
        end loop;
    end procedure;
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Procedure for generating a derived clock signal
    -- from an input clock signal with a specified division factor.
    -- usage: generate_derived_clock(clk_in, rst_n, clk_out, 4); -- Divide by 4
    ------------------------------------------------------------
    procedure generate_derived_clock(
        signal clk_in: in std_ulogic; 
        signal rst_n: in std_ulogic; 
        signal clk_out: out std_ulogic; 
        constant factor: in natural
    ) is
        constant HALF_FACTOR: natural := factor / 2; -- Half the factor for toggling
        variable counter: natural range 0 to HALF_FACTOR - 1 := HALF_FACTOR - 1;
        variable output: std_ulogic := '0';
    begin
        assert (factor mod 2 = 0) and (factor > 0)
            report "Division factor must be a positive even number"
            severity FAILURE;

        while true loop
            wait until rising_edge(clk_in);

            if rst_n = '0' then
                output := '0';
                counter := counter'subtype'high;
            elsif counter = counter'subtype'high then
                counter := 0;
                output := not output;
            else
                counter := counter + 1;
            end if;

            clk_out <= output;
        end loop;
    end procedure;
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Enhanced clock generator with precise frequency control
    -- Features: phase offset, duty cycle control, run/pause capability
    -- usage: generate_clock_advanced(sys_clk, 66.67E6, 0 fs, enable, 50.0);
    ------------------------------------------------------------
    procedure generate_clock_advanced(
        signal clk_out: out std_ulogic; 
        constant target_freq: real; 
        constant initial_delay: time := 0 fs; 
        signal enable: std_ulogic;
        constant duty: real := 50.0
    ) is
        -- Calculate time parameters
        constant full_cycle_time: time := 1.0 sec / target_freq;
        constant pulse_width: time := (duty/100.0) * full_cycle_time;
        constant idle_width: time := full_cycle_time - pulse_width;
        
        -- Tracking variables
        variable elapsed: time := 0 fs;
        variable cycle_count: integer := 0;
        variable timing_adjustment: time := 0 fs;
        variable actual_low_time: time;
    begin
        -- Parameter validation
        assert (pulse_width > 0 fs) 
            report "Clock generation failed: resolution too low for requested frequency" 
            severity FAILURE;
        
        -- Apply initial phase delay before starting
        clk_out <= '0';
        if initial_delay > 0 fs then
            wait for initial_delay;
        end if;

        -- Main clock generation loop with drift correction
        while true loop
            if enable then
                -- High portion of clock cycle
                clk_out <= '1';
                wait for pulse_width;

                -- Low portion with timing correction
                clk_out <= '0';

                -- Calculate precise low time to maintain frequency accuracy
                elapsed := elapsed + pulse_width;
                cycle_count := cycle_count + 1;
                timing_adjustment := (cycle_count * full_cycle_time) - elapsed;
                actual_low_time := idle_width + timing_adjustment;

                wait for actual_low_time;
                elapsed := elapsed + actual_low_time;
            else
                -- Clock disabled - maintain low state and wait for enable
                clk_out <= '0';
                wait until enable;
            end if;
        end loop;
    end procedure;
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Function to convert an integer vector to a string representation
    -- usage: to_string(input_vector);
    ------------------------------------------------------------
    impure function to_string(input: integer_vector) return string is
        impure function recursively_concatenate(input: integer_vector; index: natural) return string is begin
            if index = input'subtype'high then
                return to_string(input(index));
            else
                return to_string(input(index)) & ", " & recursively_concatenate(input, index + 1);
            end if;
        end function;
    begin
        return recursively_concatenate(input, index => input'subtype'low);
    end function;
end package body;
