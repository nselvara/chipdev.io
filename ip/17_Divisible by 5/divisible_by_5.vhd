--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 17
--!  @details    The trick to solve this problem is to use the remainder of the modulo 5,
--!              whereas, each bit contributes to the number.
--!              The key observation is that the divisibility of a binary number by 5 
--!              can be determined by tracking the remainder as each bit is processed.
--! @details     1. Binary representation:
--!                 - $$ N = b_k * 2^k + b_{k-1} * 2^{k-1} + ... + b_1 * 2^1 + b_0 * 2^0 $$
--!                     -  where $ b_i $ is the binary digit (0 or 1) at position $i$.
--!              2. Modulo 5 property:
--!                 - Powers of 2 repeat modulo 5 in a cycle: 2^0 ? 1, 2^1 ? 2, 2^2 ? 4, 2^3 ? 3, 2^4 ? 1, ...
--!                 - This means each bit's contribution to the modulo 5 result follows this repeating pattern.
--!              3. Remainder calculation:
--!                 1. **Modulo 5 Property**:
--!                    - Powers of 2 repeat modulo 5: 2^0 ? 1, 2^1 ? 2, 2^2 ? 4, 2^3 ? 3, 2^4 ? 1, ...
--!                    - The contribution of each bit cycles through these values modulo 5.
--!                 2. **Remainder Tracking**:
--!                    - A state machine tracks the remainder modulo 5 (`rem_0`, `rem_1`, `rem_2`, `rem_3`, `rem_4`) as bits are processed.
--!                    - The remainder wraps back to `0` when it reaches `5`, indicating divisibility by 5.
--!                 3. **Divisibility Check**:
--!                    - If the final state is `rem_0`, the binary number is divisible by 5.
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisible_by_5 is
    port (
        clk: in std_ulogic;
        rst_n: in std_ulogic;
        din: in std_ulogic;
        dout: out std_ulogic
    );
end entity;

architecture behavioural of divisible_by_5 is
    -- In theroy, if the input is 0 during reset, it's divisible by 5,
    -- however, the quest requires to ignore the 0 while resetting
    type modulo_rest_state_t is (idle, rem_0, rem_1, rem_2, rem_3, rem_4);
    signal state: modulo_rest_state_t;
begin
    binary_modulo: process(clk, rst_n)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                state <= idle;
            else
                case state is
                    when idle =>
                        state <= rem_1 when din else rem_0;
                    when rem_0 =>
                        if din then
                            state <= rem_1;
                        end if;
                    when rem_1 =>
                        state <= rem_3 when din else rem_2;
                    when rem_2 =>
                        state <= rem_0 when din else rem_4;
                    when rem_3 =>
                        state <= rem_2 when din else rem_1;
                    when rem_4 =>
                        if not din then
                            state <= rem_3;
                        end if;
                end case;
            end if;
        end if;
    end process;

    dout <= '1' when (state = rem_0) else '0';
end architecture;
