--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 17
--!  @details    VHDL module for Palindrome Detector
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity palindrome_detector is
    generic (
        DATA_WIDTH: positive := 32
    );
    port (
        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        dout: out std_ulogic
    );
end entity;

architecture behavioural of palindrome_detector is
    signal din_reversed: std_ulogic_vector(din'reverse_range);
begin
    reverser: for i in din'range generate
        din_reversed(i) <= din(i);
    end generate;
    dout <= '1' when (din = din_reversed) else '0';
end architecture;
