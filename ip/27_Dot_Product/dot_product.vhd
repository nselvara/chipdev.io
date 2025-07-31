--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 27
--!  @details    VHDL module for Dot Product
--!  @details    This module computes the dot product of two vectors.
--!  @details    The input comes in sequentially, a1, a2, a3, ... an, b1, b2, b3, ... bn.
--!  @details    Output bit width for dot product:
--!  @details    Each product: 2*DATA_WIDTH bits. 
--!  @details    Sum of VECTOR_SIZE products: needs CEIL(log2(VECTOR_SIZE)) + 2*DATA_WIDTH bits.
--!  @details    This ensures no overflow for
--!  @note       Chipdev.io lists this as quest 28
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity dot_product is
    generic (
        DATA_WIDTH: positive := 8;
        VECTOR_SIZE: positive := 3
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in unsigned(DATA_WIDTH - 1 downto 0);
        dout: out unsigned(to_bits(VECTOR_SIZE) + 2 * DATA_WIDTH - 1 downto 0);
        -- VUnit has a function named run, so we use run_out to avoid conflict
        run_out: out std_ulogic
    );
end entity;

architecture behavioural of dot_product is
begin
    calculator: process(clk, rst_n)
        constant TOTAL_VECTORS_SIZE: positive := VECTOR_SIZE * 2;
        type vectors_array_t is array (0 to TOTAL_VECTORS_SIZE - 1) of din'subtype;
        -- As we receive the vectors not like a1, b1, a2, b2, ...
        -- but like a1, a2, a3, ..., b1, b2
        -- so we need to store them in an array
        variable vectors: vectors_array_t;
        variable count: natural range 0 to TOTAL_VECTORS_SIZE - 1;

        impure function calculate_dot_product(vectors: vectors_array_t) return unsigned is
            variable result: unsigned(dout'range) := (others => '0');
        begin
            for i in 0 to VECTOR_SIZE - 1 loop
                result := result + (vectors(i) * vectors(i + VECTOR_SIZE));
            end loop;
            return result;
        end function;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                run_out <= '0';
                count := 0;
                vectors := (others => (others => '0'));
                dout <= (others => '0');
            else
                run_out <= '0';
                vectors(count) := din;

                if count >= count'subtype'high then
                    count := 0;
                    dout <= calculate_dot_product(vectors);
                    run_out <= '1';
                else
                    count := count + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
