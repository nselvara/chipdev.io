--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 24
--!  @details    VHDL module for Ripple Carry Adder
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ripple_carry_adder is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        a: in unsigned(DATA_WIDTH - 1 downto 0);
        b: in unsigned(DATA_WIDTH - 1 downto 0);
        sum: out unsigned(DATA_WIDTH downto 0);
        cout_int: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of ripple_carry_adder is
    signal cin: cout_int'subtype;
    signal sum_int: sum'subtype;
begin
    full_adder_chain: for i in 0 to DATA_WIDTH - 1 generate
        cin_selection: if (i = 0) generate
            cin(i) <= '0';
        else generate
            cin(i) <= cout_int(i - 1);
        end generate;

        sum(i) <= sum_int(i);

        full_adder_inst: entity work.full_adder(behavioural_operators_implementation)
            port map (
                a => a(i),
                b => b(i),
                cin => cin(i),
                sum => sum_int(i),
                cout => cout_int(i)
            );
    end generate;

    sum(sum'high) <= cout_int(cout_int'high);
end architecture;
