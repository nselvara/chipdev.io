--! ----------------------------------------------------------------------------
--!  @author     N. Selvarajah
--!  @brief      Based on chipdev.io question 32
--!  @details    VHDL module for a generic Carry Select Adder
--!  @details    The tricky part here is to evenly split the bits into stages.
--!              If DATA_WIDTH is not perfectly divisible by STAGES, the remaining
--!              bits are added to an additional stage at the end.
--!              For the remainder stage, we need to stop sum slicing one bit earlier
--!              so that the remainder stage can take over the final carry out bit.
--! ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity carry_select_adder is
    generic (
        DATA_WIDTH: positive := 24;
        STAGES: positive := 4
    );
    port (
        a: in unsigned(DATA_WIDTH - 1 downto 0);
        b: in unsigned(DATA_WIDTH - 1 downto 0);
        cin: in std_ulogic := '0';
        sum: out unsigned(DATA_WIDTH downto 0)
    );
end entity;

architecture behavioural of carry_select_adder is
    constant STAGE_WIDTH_REAL: real := real(DATA_WIDTH) / real(STAGES);
    constant STAGE_BLOCK_WIDTH: positive := positive(floor(STAGE_WIDTH_REAL));
    constant STAGE_REMAINDER_WIDTH: natural := DATA_WIDTH - (STAGE_BLOCK_WIDTH * STAGES);
    constant STAGE_REMAINDER_BITS_EXISTS: boolean := (STAGE_REMAINDER_WIDTH > 0);

    type unsigned_stage_array is array(0 to STAGES - 1) of unsigned;
    type unsigned_carry_bit_array is array(std_ulogic range '0' to '1') of unsigned;
    type unsigned_carry_bit_stage_array is array(0 to STAGES - 1) of unsigned_carry_bit_array;

    signal stage_block_width_a: unsigned_stage_array(open)(STAGE_BLOCK_WIDTH - 1 downto 0);
    signal stage_block_width_b: unsigned_stage_array(open)(STAGE_BLOCK_WIDTH - 1 downto 0);

    signal stage_block_width_carry_out: std_ulogic_vector(STAGES - 1 downto 0);
    signal stage_block_width_sum: unsigned_carry_bit_stage_array(open)(open)(STAGE_BLOCK_WIDTH downto 0);  -- +1 for carry out

    signal stage_remainder_width_a: unsigned(STAGE_REMAINDER_WIDTH - 1 downto 0);
    signal stage_remainder_width_b: unsigned(STAGE_REMAINDER_WIDTH - 1 downto 0);

    signal stage_remainder_width_carry_out: std_ulogic;
    signal stage_remainder_width_sum: unsigned_carry_bit_array(open)(STAGE_REMAINDER_WIDTH downto 0);
begin
    assert DATA_WIDTH >= STAGES
        report "DATA_WIDTH must be greater than or equal to STAGES"
    severity failure;

    minimum_stages: for stage_idx in 0 to STAGES - 1 generate
        stage_block_width_a(stage_idx) <= a((stage_idx + 1) * STAGE_BLOCK_WIDTH - 1 downto stage_idx * STAGE_BLOCK_WIDTH);
        stage_block_width_b(stage_idx) <= b((stage_idx + 1) * STAGE_BLOCK_WIDTH - 1 downto stage_idx * STAGE_BLOCK_WIDTH);

        -- For stage 0, use cin as carry in
        carry_in_blocks: for carry_bit in unsigned_carry_bit_array'range generate
            ripple_carry_adder_block: entity work.ripple_carry_adder
                generic map (
                    DATA_WIDTH => STAGE_BLOCK_WIDTH
                )
                port map (
                    a => stage_block_width_a(stage_idx),
                    b => stage_block_width_b(stage_idx),
                    cin => carry_bit,
                    sum => stage_block_width_sum(stage_idx)(carry_bit),
                    cout_int => open
                );
        end generate;

        -- Select the right value based on the carry in resp. out bit
        first_stage_cin_is_port_cin_case: if (stage_idx = 0) generate
            stage_block_width_carry_out(stage_idx) <= stage_block_width_sum(stage_idx)(cin)(STAGE_BLOCK_WIDTH);
            sum((stage_idx + 1) * STAGE_BLOCK_WIDTH - 1 downto stage_idx * STAGE_BLOCK_WIDTH) <= stage_block_width_sum(stage_idx)(cin)(stage_block_width_a'element'range);
        else generate
            stage_block_width_carry_out(stage_idx) <= stage_block_width_sum(stage_idx)('1')(STAGE_BLOCK_WIDTH) when stage_block_width_carry_out(stage_idx - 1) else stage_block_width_sum(stage_idx)('0')(STAGE_BLOCK_WIDTH);

            -- Take the previous carry out to select the sum
            -- NOTE: Directly slicing with stage_block_width_carry_out(stage_idx - 1) didn't work
            -- Last stage, we've to also take over the carry out
            -- If no remainder stage exists, we need to extend the sum output by 1 bit
            last_stage_sum_contains_carry_over_case: if (stage_idx = STAGES - 1) and not STAGE_REMAINDER_BITS_EXISTS generate
                sum((stage_idx + 1) * STAGE_BLOCK_WIDTH downto stage_idx * STAGE_BLOCK_WIDTH) <= stage_block_width_sum(stage_idx)('1') when stage_block_width_carry_out(stage_idx - 1) else stage_block_width_sum(stage_idx)('0');
            else generate
                sum((stage_idx + 1) * STAGE_BLOCK_WIDTH - 1 downto stage_idx * STAGE_BLOCK_WIDTH) <= stage_block_width_sum(stage_idx)('1')(stage_block_width_a'element'range) when stage_block_width_carry_out(stage_idx - 1) else stage_block_width_sum(stage_idx)('0')(stage_block_width_a'element'range);
            end generate;
        end generate;
    end generate;

    -- Additional stage if there are remainder bits
    remainder_stage: if STAGE_REMAINDER_BITS_EXISTS generate
        stage_remainder_width_a <= a(a'high downto a'high - STAGE_REMAINDER_WIDTH + 1);
        stage_remainder_width_b <= b(b'high downto b'high - STAGE_REMAINDER_WIDTH + 1);

        carry_in_stages: for carry_bit in unsigned_carry_bit_array'range generate
            ripple_carry_adder_inst: entity work.ripple_carry_adder
                generic map (
                    DATA_WIDTH => STAGE_REMAINDER_WIDTH
                )
                port map (
                    a => stage_remainder_width_a,
                    b => stage_remainder_width_b,
                    cin => carry_bit,
                    sum => stage_remainder_width_sum(carry_bit),
                    cout_int => open
                );
        end generate;

        -- NOTE: Directly slicing with stage_block_width_carry_out(stage_idx - 1) didn't work
        stage_remainder_width_carry_out <= stage_remainder_width_sum('1')(stage_remainder_width_sum'element'high) when stage_block_width_carry_out(stage_block_width_carry_out'high) else stage_remainder_width_sum('0')(stage_remainder_width_sum'element'high);
        sum(DATA_WIDTH downto DATA_WIDTH - STAGE_REMAINDER_WIDTH) <= stage_remainder_width_sum('1')(stage_remainder_width_sum'element'high downto stage_remainder_width_sum'element'high - STAGE_REMAINDER_WIDTH) when stage_block_width_carry_out(stage_block_width_carry_out'high) else stage_remainder_width_sum('0')(stage_remainder_width_sum'element'high downto stage_remainder_width_sum'element'high - STAGE_REMAINDER_WIDTH);
    end generate;
end architecture;
