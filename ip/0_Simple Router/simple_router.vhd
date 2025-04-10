-- ----------------------------------------------------------------------------
--  @author     N. Selvarajah
--  @brief      Based on chipdev.io question 1
--  @details    Simple router that directs input data to one of four outputs based on a 2-bit address
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity simple_router is
    generic (
        DATA_WIDTH: positive := 32
    );
    port (
        din: in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        din_en: in std_ulogic;
        addr: in std_ulogic_vector(1 downto 0); -- No generic, as the outputs are fixed to 4
        dout0: out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        dout1: out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        dout2: out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
        dout3: out std_ulogic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture behavioural of simple_router is
begin
    router: process(all)
    begin
        dout0 <= (others => '0');
        dout1 <= (others => '0');
        dout2 <= (others => '0');
        dout3 <= (others => '0');

        if din_en then
            case addr is
                when "00" => dout0 <= din;
                when "01" => dout1 <= din;
                when "10" => dout2 <= din;
                when "11" => dout3 <= din;
                when others => null; -- All outputs are zeroed above; this is just safety
            end case;
        end if;
    end process;
end architecture;
