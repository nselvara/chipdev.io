--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 34
--!  @details    VHDL module for Mealy Finite State Machine
--!  @details    Ouputs depend on both the present state and the current inputs.
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mealy_finite_state_machine is
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic;
        cen: in std_ulogic;
        doutx: out std_ulogic;
        douty: out std_ulogic
    );
end entity;

architecture behavioural of mealy_finite_state_machine is
    type state_t is (S0, S1, S2, S3, S4);
    signal present_state, next_state: state_t;
    signal din_reg: std_ulogic;
    signal cen_reg: std_ulogic;
begin
    state_register: process(clk, rst_n)
    begin
        if rst_n = '0' then
            present_state <= S0;
            din_reg <= '0';
            cen_reg <= '0';
        elsif rising_edge(clk) then
            present_state <= next_state;
            din_reg <= din;
            cen_reg <= cen;
        end if;
    end process;

    next_state_logic: process(present_state, din_reg)
    begin
        next_state <= present_state;

        case present_state is
            -- Initial state
            when S0 =>
                next_state <= S3 when din_reg else S1;
            -- Saw one 0 or two or more 0s (000, 010, 100, 110)
            when S1 | S2 =>
                next_state <= S3 when din_reg else S2;
            -- Saw one 1 or two or more 1s (111, 101, 011, 001)
            when S3 | S4 =>
                next_state <= S4 when din_reg else S1;
            when others =>
                next_state <= S0;
        end case;
    end process;

    output_logic: process(present_state, din_reg, cen_reg)
    begin
        doutx <= '0';
        douty <= '0';

        if ((present_state = S1 or present_state = S2) and din_reg = '0') or ((present_state = S3 or present_state = S4) and din_reg = '1') then
            doutx <= cen_reg;
        end if;

        if (present_state = S2 and din_reg = '0') or (present_state = S4 and din_reg = '1') then
            douty <= cen_reg;
        end if;
    end process;
end architecture;
