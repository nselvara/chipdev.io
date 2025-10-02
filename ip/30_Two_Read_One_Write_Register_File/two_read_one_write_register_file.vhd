--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 30
--!  @details    VHDL module for Two Read One Write Register File
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity two_read_one_write_register_file is
    generic (
        DATA_WIDTH: positive := 16;
        ADDRESS_WIDTH: positive range 1 to to_bits(positive'high) := 5
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;

        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        wad1: in std_ulogic_vector(ADDRESS_WIDTH - 1 downto 0);
        rad1: in std_ulogic_vector(ADDRESS_WIDTH - 1 downto 0);
        rad2: in std_ulogic_vector(ADDRESS_WIDTH - 1 downto 0);
        wen1: in std_ulogic;
        ren1: in std_ulogic;
        ren2: in std_ulogic;

        dout1: out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        dout2: out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        collision: out std_ulogic
    );
end entity;

architecture behavioural of two_read_one_write_register_file is
    constant REGISTER_DEPTH: positive := 2**ADDRESS_WIDTH;
    type memory_array is array (0 to REGISTER_DEPTH - 1) of std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    signal memory: memory_array;
begin
    register_file: process(clk, rst_n)
        variable collision_v: std_ulogic;
    begin
        if rising_edge(clk) then
            dout1 <= (others => '0');
            dout2 <= (others => '0');
            collision_v := '0';

            if rst_n = '0' then
                memory <= (others => (others => '0'));
            else
                if (rad1 = rad2) then
                    collision_v := ren1 and ren2;
                elsif (wad1 = rad1) then
                    collision_v := wen1 and ren1;
                elsif (wad1 = rad2) then
                    collision_v := wen1 and ren2;
                end if;

                if not collision_v then
                    if wen1 then
                        memory(to_integer(unsigned(wad1))) <= din;
                    end if;

                    if ren1 then
                        dout1 <= memory(to_integer(unsigned(rad1)));
                    end if;

                    if ren2 then
                        dout2 <= memory(to_integer(unsigned(rad2)));
                    end if;
                end if;
            end if;
        end if;

        collision <= collision_v;
    end process;
end architecture;
