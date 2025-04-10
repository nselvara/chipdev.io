-- ----------------------------------------------------------------------------
--  @author     N. Selvarajah
--  @brief      Based chipdev.io question 2
--  @details    Displays the second largest number in a clocked sequence of numbers based on din
--  @details    If the input sequence stays the same, the output will be 0
-- -------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity second_largest is
    generic (
        DATA_WIDTH: positive := 32
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in unsigned(DATA_WIDTH - 1 downto 0);
        dout: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of second_largest is
begin
    filter: process(clk, rst_n)
        variable largest_value: din'subtype;
        variable second_largest_value: din'subtype;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                largest_value := to_unsigned(0, largest_value'length);
                second_largest_value := to_unsigned(0, second_largest_value'length);
            else
                if din > largest_value then
                    second_largest_value := largest_value;
                    largest_value := din;
                elsif din > second_largest_value and din /= largest_value then
                    second_largest_value := din;
                end if;
            end if;
        end if;

        dout <= second_largest_value;
    end process;
end architecture;
