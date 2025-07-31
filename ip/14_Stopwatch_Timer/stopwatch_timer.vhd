--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 14
--!  @details    VHDL module for Stopwatch Timer
--!  @note       As stop is a VHDL-2008 reserved word, it is renamed to stop_in, 
--!              thus, following the naming convention of the other signals.
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch_timer is
    generic (
        DATA_WIDTH: positive := 16;
        MAX: positive := 99
    );
    port (
        clk: in std_ulogic;
        reset: in std_ulogic;
        start_in: in std_ulogic;
        stop_in: in std_ulogic;
        count_out: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of stopwatch_timer is
begin
    stopwatch: process(clk)
        variable start_reg: std_ulogic;
    begin
        if rising_edge(clk) then
            if reset then
                count_out <= (others => '0');
                start_reg := '0';
            elsif stop_in then
                start_reg := '0';
            elsif start_in or start_reg then
                start_reg := '1';

                if count_out < to_unsigned(MAX, count_out'length) then
                    count_out <= count_out + 1;
                else
                    count_out <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end architecture;
