--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 20
--!  @details    VHDL module for Divide by Evens Clock Divider
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divide_by_evens_clock_divider is
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        clk_div_2: out std_ulogic;
        clk_div_4: out std_ulogic;
        clk_div_6: out std_ulogic
    );
end entity;

architecture behavioural of divide_by_evens_clock_divider is
begin
    clk_divider: process(clk)
        constant DIVISION_FACTOR_4: natural := 4;
        constant DIVISION_FACTOR_6: natural := 6;

        -- /2 as we toggle the clock on both edges
        variable clk_4_counter: natural range 0 to DIVISION_FACTOR_4 / 2 - 1;
        variable clk_6_counter: natural range 0 to DIVISION_FACTOR_6 / 2 - 1;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                clk_div_2 <= '0';
                clk_div_4 <= '0'; 
                clk_div_6 <= '0';
                clk_4_counter := clk_4_counter'subtype'high;
                clk_6_counter := clk_6_counter'subtype'high;
            else
                clk_div_2 <= not clk_div_2;

                if clk_4_counter < clk_4_counter'subtype'high  then
                    clk_4_counter := clk_4_counter + 1;
                else
                    clk_4_counter := 0;
                    clk_div_4 <= not clk_div_4;
                end if;

                if clk_6_counter < clk_6_counter'subtype'high then
                    clk_6_counter := clk_6_counter + 1;
                else
                    clk_6_counter := 0;
                    clk_div_6 <= not clk_div_6;
                end if;
            end if;
        end if;
    end process;
end architecture;
