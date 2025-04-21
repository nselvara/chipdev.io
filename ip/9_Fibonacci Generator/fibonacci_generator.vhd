--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 9
--!  @details    VHDL module for Fibonacci Generator
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fibonacci_generator is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        dout: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of fibonacci_generator is
    type unsigned_array is array (natural range <>) of unsigned(dout'range);
    constant FIRST_2_FIBONACCI: unsigned_array(1 downto 0) := (others => to_unsigned(1, unsigned_array'element'length));
    signal fibonacci_pipeline: FIRST_2_FIBONACCI'subtype;
begin
    fibonacci_calculation: process(clk)
        variable sum: unsigned_array'element;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                fibonacci_pipeline <= FIRST_2_FIBONACCI;
            else
                sum := resize(fibonacci_pipeline(1) + fibonacci_pipeline(0), sum'length);
                fibonacci_pipeline <= fibonacci_pipeline(0) & sum;
            end if;

            dout <= fibonacci_pipeline(1);
        end if;
    end process;
end architecture;
