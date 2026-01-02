--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 33
--!  @details    VHDL module for Bubble Sort
--!  @details    Basically, repeatedly steps through the list, compares adjacent elements
--!              and swaps them if they are in the wrong order. The pass through the list
--!              is repeated until the list is sorted.
--!  @note       This means in worst case, it has a time complexity of O(n^2)
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity bubble_sort is
    generic (
        BITWIDTH: positive := 3;
        VECTOR_SIZE: positive range 1 to to_bits(positive'high) := 8
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic_vector(BITWIDTH - 1 downto 0);
        sortit: in std_ulogic;
        dout: out std_ulogic_vector(VECTOR_SIZE * BITWIDTH downto 0)
    );
end entity;

architecture behavioural of bubble_sort is
begin
    bubble_sorter: process(clk)
        type memory_array_t is array (0 to VECTOR_SIZE - 1) of din'subtype;
        variable memory: memory_array_t;
        variable temp: din'subtype;
        variable counter: natural range 0 to VECTOR_SIZE - 1 := 0;
        variable sorted_vector: dout'subtype;

        impure function bubble_sorter return memory_array_t is
            variable swap: boolean;
            variable lower_idx_value, higher_idx_value: unsigned(din'range);
        begin
            for i in VECTOR_SIZE - 1 downto 0 loop
                inner_loop: for mem_idx in 1 to VECTOR_SIZE - 1 loop
                    lower_idx_value := unsigned(memory(mem_idx - 1));
                    higher_idx_value := unsigned(memory(mem_idx));
                    swap := lower_idx_value > higher_idx_value;
                    if swap then
                        temp := memory(mem_idx - 1);
                        memory(mem_idx - 1) := memory(mem_idx);
                        memory(mem_idx) := temp;
                    end if;
                    exit inner_loop when mem_idx >= i;
                end loop;
            end loop;

            return memory;
        end function;

        impure function get_sorted_vector return dout'subtype is
            variable result: dout'subtype := (others => '0');
        begin
            -- Map the MSB to the lowest index
            for idx in 0 to VECTOR_SIZE - 1 loop
                result((idx + 1) * BITWIDTH - 1 downto idx * BITWIDTH) := memory(VECTOR_SIZE - 1 - idx);
            end loop;
            return result;
        end function;
    begin
        -- NOTE: Order of operations is important here
        if rising_edge(clk) then
            if rst_n = '0' then
                memory := (others => (others => '0'));
                counter := 0;
                sorted_vector := (others => '0');
            elsif not sortit then
                memory(counter) := din;
                counter := counter + 1 when counter < VECTOR_SIZE - 1 else 0;
            else
                memory := bubble_sorter;
                sorted_vector := get_sorted_vector;
            end if;
        end if;

        dout <= sorted_vector;
    end process;
end architecture;
