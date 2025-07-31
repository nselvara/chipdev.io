--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 15
--!  @details    VHDL module for Sequence Detector
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sequence_detector is
    generic (
        SEQUENCE_PATTERN: std_ulogic_vector
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic;
        dout: out std_ulogic
    );
end entity;

architecture behavioural of sequence_detector is
    -- We've to use the reverse range to get the correct order of bits
    signal shift_reg: std_ulogic_vector(SEQUENCE_PATTERN'reverse_range);
begin
    sequence_detector_process: process(clk, rst_n)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                shift_reg <= (others => '0');
            else
                -- During compilation, only one would be implemented
                if shift_reg'ascending then
                    shift_reg <= din & shift_reg(0 to shift_reg'high - 1);
                else
                    shift_reg <= shift_reg(shift_reg'high - 1 downto 0) & din;
                end if;
            end if;
        end if;
    end process;

    dout <= '1' when (shift_reg = SEQUENCE_PATTERN) else '0';
end architecture;
