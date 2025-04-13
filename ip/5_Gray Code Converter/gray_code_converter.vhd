--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 4
--!  @details    VHDL module for Gray Code Converter
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gray_code_converter is
    generic (
        DATA_WIDTH: integer := 4
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        dout: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of gray_code_converter is
begin
    gray_code_counter: process(clk, rst_n)
    variable count: dout'subtype := (others => '0');
    begin
        if rst_n = '0' then
            count := (others => '0');
        elsif rising_edge(clk) then
            count := count + 1;
        end if;

        dout <= count xor shift_right(count, 1);
    end process gray_code_counter;
end architecture;
