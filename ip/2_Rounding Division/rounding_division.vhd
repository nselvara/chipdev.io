--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 3
--!  @details    VHDL module for Rounding Division
--!  @details    Remainders of 0.5 or greater should be rounded up to the nearest integer.
--!  @details    If the output were to overflow, then the result should be saturated instead.
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rounding_division is
    generic (
        DIV_LOG2: positive := 3;
        OUT_WIDTH: positive := 32;
        IN_WIDTH: positive := OUT_WIDTH + DIV_LOG2
    );
    port (
        din: in unsigned(IN_WIDTH - 1 downto 0);
        dout: out unsigned(OUT_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of rounding_division is
begin
    divider: process(all)
        variable quotient: dout'subtype;
    begin
        quotient := resize(shift_left(din, DIV_LOG2), quotient'length) when din'ascending else resize(shift_right(din, DIV_LOG2), quotient'length);

        -- The highest bit of the fractional part (din(DIV_LOG2 - 1..0)) is basically 2^(-1) = 0.5
        -- If the remainder is greater than or equal to 0.5, we need to round up
        if din(DIV_LOG2 - 1) then
            quotient := resize(quotient + 1, quotient'length);
        end if;

        dout <= quotient;
    end process;
end architecture;
