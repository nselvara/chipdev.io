--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 5
--!  @details    VHDL module for Bit Reverser
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bit_reverser is
    generic (
        DATA_WIDTH: integer := 32
    );
    port (
        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        dout: out std_ulogic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of bit_reverser is
begin
    reverser: process(all)
    begin
        for i in din'range loop
            dout(i) <= din(din'high - i);
        end loop;
    end process reverser;
end architecture;
