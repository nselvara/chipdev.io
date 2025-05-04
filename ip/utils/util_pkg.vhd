--! 
--! @author:    N. Selvarajah
--! @brief:     This pkg contains utility functions and constants used in the project.
--! @details:   
--!
--! @license    This project is released under the terms of the GNU GENERAL PUBLIC LICENSE v3. See LICENSE for more details.
--! 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package util_pkg is
    function to_bits(x: natural) return natural;
    function to_bits(x: real) return natural;
    function "??"(right: boolean) return std_ulogic;
    ------------------------------------------------------------
    -- Function to read a file and return the number of characters
    -- usage: file_length_in_characters("filename.txt");
    ------------------------------------------------------------
    impure function file_length_in_characters(filename: string) return natural;

    ------------------------------------------------------------
    -- Function to get stats about a std_ulogic_vector
    -- usage: get_amount_of_state(data, '1');
    ------------------------------------------------------------
    function get_amount_of_state(data: std_ulogic_vector; state: std_ulogic) return unsigned;
    function get_amount_of_state(data: std_ulogic_vector; state: std_ulogic) return natural;

    ------------------------------------------------------------
    -- Function to get the amount of trailing state in a std_ulogic_vector
    -- usage: get_amount_of_trailing_state(data, '1');
    ------------------------------------------------------------
    function get_amount_of_trailing_state(data: std_ulogic_vector; state: std_ulogic) return unsigned;
    function get_amount_of_trailing_state(data: std_ulogic_vector; state: std_ulogic) return natural;
end package;

package body util_pkg is
    function to_bits(x: real) return natural is begin
        return natural(ceil(log2(x)));
    end function;

    function to_bits(x: natural) return natural is begin
        return to_bits(real(x));
    end function;

    function "??"(right: boolean) return std_ulogic is begin
        if right then
            return '1';
        else
            return '0';
        end if;
    end function;

    impure function file_length_in_characters(filename: string) return natural is
        type char_file_t is file of character;
        file char_file : char_file_t;
        variable char_v : character;
        variable res_v : natural;
    begin
        res_v := 0;
        file_open(char_file, filename, read_mode);

        while not endfile(char_file) loop
            read(char_file, char_v);
            res_v := res_v + 1;
        end loop;

        file_close(char_file);
        return res_v;
    end function;
    
    function get_amount_of_state(data: std_ulogic_vector; state: std_ulogic) return unsigned is
        variable res_v : unsigned(to_bits(data'length) - 1 downto 0) := (others => '0');
    begin
        for i in data'range loop
            if data(i) = state then
                res_v := res_v + 1;
            end if;
        end loop;
        return res_v;
    end function;

    function get_amount_of_state(data: std_ulogic_vector; state: std_ulogic) return natural is begin
        return to_integer(resize(get_amount_of_state(data => data, state => state), to_bits(natural'high)));
    end function;

    function get_amount_of_trailing_state(data: std_ulogic_vector; state: std_ulogic) return unsigned is
        -- +1 for the maximum amount of trailing zeroes
        variable trailing_state_amount: unsigned(to_bits(data'length) downto 0) := (others => '0');
    begin
        for i in data'low to data'high loop
            if data(i) = state then 
                trailing_state_amount := trailing_state_amount + 1;
            else
                exit;
            end if;
        end loop;

        return trailing_state_amount;
    end function;

    function get_amount_of_trailing_state(data: std_ulogic_vector; state: std_ulogic) return natural is begin
        return to_integer(resize(get_amount_of_trailing_state(data => data, state => state), to_bits(natural'high)));
    end function;
end package body;
