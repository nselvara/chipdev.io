--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question
--!  @details    VHDL module for Basic ALU
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- filepath: c:\Repos\chipdev.io\ip\23_Basic ALU\basic_alu.vhd
entity basic_alu is
    generic (
        DATA_WIDTH: positive := 32
    );
    port (
        a: in unsigned(DATA_WIDTH - 1 downto 0);
        b: in unsigned(DATA_WIDTH - 1 downto 0);
        a_plus_b: out unsigned(DATA_WIDTH - 1 downto 0);
        a_minus_b: out unsigned(DATA_WIDTH - 1 downto 0);
        not_a: out unsigned(DATA_WIDTH - 1 downto 0);
        a_and_b: out unsigned(DATA_WIDTH - 1 downto 0);
        a_or_b: out unsigned(DATA_WIDTH - 1 downto 0);
        a_xor_b: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of basic_alu is
begin
    a_plus_b <= resize(a + b, a_plus_b'length);
    a_minus_b <= resize(a - b, a_minus_b'length);
    not_a <= not a;
    a_and_b <= a and b;
    a_or_b <= a or b;
    a_xor_b <= a xor b;
end architecture;
