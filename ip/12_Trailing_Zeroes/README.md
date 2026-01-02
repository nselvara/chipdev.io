# Quest 12 – Trailing Zeroes

## Original Problem Statement

### Prompt

Find the number of trailing `0`s in the binary representation of the input (`din`). If the input value is all `0`s, the number of trailing `0`s is the data width (`DATA_WIDTH`)

### Input and Output Signals

- `din` - Input value
- `dout` - Number of trailing `0`s

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/12>

## Description

Counts consecutive zero bits starting from the LSB.
Uses the `get_amount_of_trailing_state()` utility function to identify how many zeros appear before the first '1' bit.
The output width includes an extra bit (`to_bits(DATA_WIDTH) + 1`) to represent the case where all bits are zero.

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/12).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/12>
