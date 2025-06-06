--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 10
--!  @details    VHDL module for Counting Ones
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity counting_ones is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        din: in unsigned(DATA_WIDTH - 1 downto 0);
        dout: out unsigned(to_bits(DATA_WIDTH) - 1 downto 0)
    );
end entity;

architecture behavioural of counting_ones is
begin
    dout <= get_amount_of_state(data => std_ulogic_vector(din), state => '1');
end architecture;
