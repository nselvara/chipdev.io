# Quest 10 – Counting Ones

## Original Problem Statement

### Prompt

Given an input binary value, output the number of bits that are equal to `1`.

### Input and Output Signals

- `din` - Input value
- `dout` - Number of `1`'s in the input value

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/10>

## Description

Population count (popcount) circuit that returns the number of '1' bits in the input vector.
Implemented using the `get_amount_of_state()` utility function from the utils package which counts occurrences of a specified bit state.
The output width is `ceil(log2(DATA_WIDTH))` bits to accommodate the maximum possible count.

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/10).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/10>
