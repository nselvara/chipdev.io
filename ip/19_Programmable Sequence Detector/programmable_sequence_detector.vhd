--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 18
--!  @details    VHDL module for Programmable Sequence Detector
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity programmable_sequence_detector is
    generic (
        DATA_WIDTH: positive := 5
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        init: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        din: in std_ulogic;
        seen: out std_ulogic
    );
end entity;

architecture behavioural of programmable_sequence_detector is
    signal init_reg: init'subtype;
    signal shift_reg: init'subtype;
    signal din_count: natural range 0 to DATA_WIDTH;
begin
    process(clk, rst_n)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                init_reg <= init;
                din_count <= 0;
            else
                shift_reg <= shift_reg(shift_reg'high - 1 downto 0) & din;
                -- Stay once the sequence is detected
                if din_count < din_count'subtype'high then
                    din_count <= din_count + 1;
                end if;
            end if;
        end if;
    end process;

    seen <= '1' when (shift_reg = init_reg) and (din_count = din_count'subtype'high) else '0';
end architecture;
