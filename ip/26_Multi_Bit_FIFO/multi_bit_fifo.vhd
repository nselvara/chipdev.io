--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 26
--!  @details    VHDL module for Multi Bit FIFO
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multi_bit_fifo is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        wr: in std_ulogic;
        dout: out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        full: out std_ulogic;
        empty: out std_ulogic
    );
end entity;

architecture behavioural of multi_bit_fifo is
begin
    fifo: process(clk, rst_n)
        constant FIFO_DEPTH: positive := 2;

        -- NOTE: -1, is a bit dirty, but holds the empty state's zero value
        -- This is a workaround for the limitation of VHDL doing math on write_count - 1 even if one would use if/when-else exclusion
        -- For example: dout <= (others => '0') when empty else memory(write_count - 1);
        subtype fifo_depth_t is integer range -1 to FIFO_DEPTH - 1;
        type slv_array is array (fifo_depth_t) of din'subtype;
        variable memory: slv_array;

        subtype write_count_t is natural range 0 to FIFO_DEPTH;
        variable write_count: write_count_t;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                memory := (others => (others => '0'));
                write_count := 0;
            elsif wr then
                for i in 1 to FIFO_DEPTH - 1 loop
                    memory(i) := memory(i - 1);
                end loop;

                memory(0) := din;

                if write_count < write_count'subtype'high then
                    write_count := write_count + 1;
                end if;
            end if;
        end if;

        empty <= '1' when write_count = 0 else '0';
        full <= '1' when write_count = write_count'subtype'high else '0';
        dout <= memory(write_count - 1);
    end process;
end architecture;
