--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 25
--!  @details    VHDL module for Flip Flop Array
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity flip_flop_array is
    generic (
        DATA_WIDTH: positive := 8;
        -- NOTE: Arrays can only use scalar types as range in VHDL (see IEEE Std 1076-2008, section 5.2.1)
        -- whereas in VHDL-2008, 31-bits is the maximum for a positive range
        -- To circumvent this, we could make an array of array (slv_array) and split the address space
        -- but that would be more complex and an overkill for this example
        ADDRESS_WIDTH: positive range positive'low to to_bits(positive'high) - 1 := 8
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        addr: in unsigned(ADDRESS_WIDTH - 1 downto 0);
        wr: in std_ulogic;
        rd: in std_ulogic;
        dout: out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        error: out std_ulogic
    );
end entity;

architecture behavioural of flip_flop_array is
begin
    process(clk, rst_n)
        type slv_array is array (2**ADDRESS_WIDTH - 1 downto 0) of din'subtype;
        variable ff_array: slv_array;
    begin
        if rising_edge(clk) then
            error <= '0';

            if rst_n = '0' then
                ff_array := (others => (others => '0'));
                dout <= (others => '0');
            elsif wr and rd then
                error <= '1';
                dout <= (others => '0');
            elsif wr then
                ff_array(to_integer(addr)) := din;
            elsif rd then
                dout <= ff_array(to_integer(addr));
            end if;
        end if;
    end process;
end architecture;
