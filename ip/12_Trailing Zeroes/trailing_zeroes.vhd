--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 12
--!  @details    VHDL module for Trailing Zeroes
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util_pkg.all;

entity trailing_zeroes is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        dout: out unsigned(to_bits(DATA_WIDTH) downto 0) -- +1 for the maximum amount of trailing zeroes
    );
end entity;

architecture behavioural of trailing_zeroes is
begin
    dout <= get_amount_of_trailing_state(data => din, state => '0');
end architecture;
