--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 11
--!  @details    VHDL module for Gray Code to Binary
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gray_code_to_binary is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        din: in unsigned(DATA_WIDTH - 1 downto 0);
        dout: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of gray_code_to_binary is
begin
    process(all)
        variable binary: din'subtype;
        variable mask: din'subtype;
    begin
        binary := din;
        mask := din;

        while mask /= 0 loop
            mask := shift_right(mask, 1);
            binary := binary xor mask;
        end loop;

        dout <= binary;
    end process;
end architecture;
