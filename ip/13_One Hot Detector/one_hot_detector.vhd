--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 13
--!  @details    VHDL module for One-Hot Detector
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util_pkg.all;

entity one_hot_detector is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        one_hot: out std_ulogic
    );
end entity;

architecture behavioural of one_hot_detector is
begin
    one_hot <= '1' when is_one_hot(din) else '0';
end architecture;
