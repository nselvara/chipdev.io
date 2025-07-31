--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 22
--!  @details    VHDL module for Full Adder
--!  @details    This module implements a Full Adder using both behavioural operators and gate-level implementations.
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
    port (
        a: in std_ulogic;
        b: in std_ulogic;
        cin: in std_ulogic;
        sum: out std_ulogic;
        cout: out std_ulogic
    );
end entity;

architecture behavioural_operators_implementation of full_adder is
    signal tmp_sum: unsigned(1 downto 0);
begin
    tmp_sum <= (unsigned'("0" & a)) + (0 => b);
    (cout, sum) <= tmp_sum + (0 => cin);
end architecture;

architecture behavioural_gate_implementation of full_adder is
begin
    -- NOTE: This only works for single-bit I/O, not for vectors.
    sum <= a xor b xor cin;
    cout <= (a and b) or (b and cin) or (cin and a);
end architecture;
