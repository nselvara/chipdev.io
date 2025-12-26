--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 31
--!  @details    VHDL module for Configurable LFSR
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity configurable_lfsr is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in  std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        tap: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        dout: out std_ulogic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of configurable_lfsr is
begin
    lfsr: process(clk)
        variable shift_reg: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        variable tap_reg: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        variable feedback: std_ulogic := '0';
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                dout <= din;
                shift_reg := din;
                tap_reg := tap;
            else
                -- Calculate feedback bit using XOR to get odd/even parity in tap positions
                feedback := xor(tap_reg and shift_reg);
                shift_reg := shift_reg(shift_reg'high - 1 downto shift_reg'low) & feedback;
                dout <= shift_reg;
            end if;
        end if;
    end process;
end architecture;
