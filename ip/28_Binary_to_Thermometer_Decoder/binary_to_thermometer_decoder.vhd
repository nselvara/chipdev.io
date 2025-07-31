--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 28
--!  @details    VHDL module for Binary to Thermometer Decoder
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity binary_to_thermometer_decoder is
    generic (
        THERMOMETER_WIDTH: positive := 256
    );
    port (
        din: in std_ulogic_vector(to_bits(THERMOMETER_WIDTH) - 1 downto 0);
        dout: out std_ulogic_vector(THERMOMETER_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of binary_to_thermometer_decoder is
begin
    -- NOTE: Writing like this: dout(to_integer(unsigned(din)) downto 0) <= (others => '1');
    --       is not synthesizable, as it requires a constant range.
    decoder: process(all)
    begin
        dout <= (others => '0');

        for i in 0 to THERMOMETER_WIDTH - 1 loop
            if i <= unsigned(din) then
                dout(i) <= '1';
            end if;
        end loop;
    end process;
end architecture;
