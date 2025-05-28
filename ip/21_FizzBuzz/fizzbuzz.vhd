--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 21
--!  @details    VHDL module for FizzBuzz
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fizzbuzz is
    generic (
        -- NOTE: In VHDL, generic and port names must be unique
        -- ChipDev.io implements it with the same name
        FIZZ_CYCLES: positive := 3;
        BUZZ_CYCLES: positive := 5;
        MAX_CYCLES: positive := 100
    );
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        fizz: out std_ulogic;
        buzz: out std_ulogic;
        fizzbuzz: out std_ulogic
    );
end entity;

architecture behavioural of fizzbuzz is
    signal cycle_count: natural range 0 to MAX_CYCLES - 1;
    signal fizz_counter: natural range 0 to FIZZ_CYCLES - 1;
    signal buzz_counter: natural range 0 to BUZZ_CYCLES - 1;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                -- Duting reset, the outputs have to be set to '1', thus we set the counters to their maximum values
                cycle_count <= cycle_count'subtype'high;
                fizz_counter <= fizz_counter'subtype'high;
                buzz_counter <= buzz_counter'subtype'high;
            else
                -- NOTE: The order of operations matters here
                fizz_counter <= fizz_counter + 1 when fizz_counter < fizz_counter'subtype'high else 0;
                buzz_counter <= buzz_counter + 1 when buzz_counter < buzz_counter'subtype'high else 0;

                if cycle_count < cycle_count'subtype'high then
                    cycle_count <= cycle_count + 1;
                else
                    cycle_count <= 0;
                    fizz_counter <= 0;
                    buzz_counter <= 0;
                end if;
            end if;
        end if;
    end process;

    fizz <= '1' when (fizz_counter = fizz_counter'subtype'high) else '0';
    buzz <= '1' when (buzz_counter = buzz_counter'subtype'high) else '0';
    fizzbuzz <= fizz and buzz;
end architecture;
