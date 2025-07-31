--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 8
--!  @details    VHDL module for Deserialiser
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deserialiser is
    generic (
        DATA_WIDTH : positive := 16
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic;
        dout: out std_ulogic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of deserialiser is
begin
    deserialiser_process: process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                dout <= (others => '0');
            else
                dout <= dout(dout'high - 1 downto 0) & din;
            end if;
        end if;
    end process;
end architecture;
