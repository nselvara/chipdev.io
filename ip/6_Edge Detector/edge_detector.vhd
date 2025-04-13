--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 6
--!  @details    VHDL module for Edge Detector
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_detector is
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic;
        dout: out std_ulogic
    );
end entity;

architecture behavioural of edge_detector is
    signal din_reg: std_ulogic;
begin
    pulse_detector: process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                dout <= '0';
                din_reg <= '0';
            else
                dout <= '1' when din /= din_reg and din = '1' else '0';
                din_reg <= din;
            end if;
        end if;
    end process;
end architecture;
