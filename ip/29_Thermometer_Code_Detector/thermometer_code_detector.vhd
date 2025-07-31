--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question
--!  @details    VHDL module for Thermometer Code Detector
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity thermometer_code_detector is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        codeIn: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        isThermometer: out std_ulogic
    );
end entity;

architecture behavioural of thermometer_code_detector is
begin
    process(all)
        function is_thermometer_code(code: std_ulogic_vector) return boolean is
            variable number_of_transitions: natural := 0;
        begin
            if not code(0) then
                return false;
            elsif code = (code'range => '1') then
                return true;
            end if;

            for i in 1 to code'high loop
                if code(i) /= code(i - 1) then
                    number_of_transitions := number_of_transitions + 1;
                end if;
                exit when number_of_transitions > 1;
            end loop;

            return number_of_transitions = 1;
        end function;
    begin
        isThermometer <= '1' when is_thermometer_code(code => codeIn) else '0';
    end process;
end architecture;
