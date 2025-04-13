--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 7
--!  @details    VHDL module for Serialiser
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serialiser is
    generic (
        DATA_WIDTH : positive := 16
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        din_en: in std_ulogic;
        dout: out std_ulogic
    );
end entity;

architecture behavioural of serialiser is
    signal bit_index: natural range din'range := 0;
    signal din_reg: din'subtype;
begin
    serialiser_process: process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                dout <= '0';
                din_reg <= (others => '0');
                bit_index <= 0;
            elsif din_en then
                din_reg <= din;
                -- Only reset when din_en is asserted
                bit_index <= 0;
            elsif bit_index < bit_index'subtype'high then
                bit_index <= bit_index + 1;
            else
                -- Reset dout when all bits are sent
                din_reg <= (others => '0');
            end if;

            dout <= din_reg(bit_index);
        end if;
    end process;
end architecture;
