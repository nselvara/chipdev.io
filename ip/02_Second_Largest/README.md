# Quest 2 – Second Largest

## Original Problem Statement

### Prompt

Given a clocked sequence of unsigned values, output the second-largest value seen so far in the sequence. If only one value is seen, then the output (dout) should equal 0. Note that repeated values are treated as separate candidates for being the second largest value.

When the reset-low signal (`resetn`) goes low, all previous values seen in the input sequence should no longer be considered for the calculation of the second largest value, and the output dout should restart from 0 on the next cycle.

### Input and Output Signals

`clk` - Clock signal
`resetn` - Synchronous reset-low signal
`din` - Input data sequence
`dout` - Second-largest value seen so far

### Output signals during reset

`dout` - 0 when resetn is active

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/2>

## Description

Design a sequential circuit that monitors a stream of unsigned values and continuously outputs the **second-largest value** observed so far. If only a single value has been seen, then the output (`dout`) must remain `0`.

Each value, even if repeated, should be treated as a distinct observation. That means duplicates are still valid inputs when determining the second largest.

If the active-low reset (`resetn`) signal is asserted, any previously observed values must be discarded, and the calculation of the second-largest value starts fresh. In this reset state, `dout` should immediately return to `0`.

---

## Source Reference

This task is inspired by the "Second Largest" problem available at [chipdev.io](https://chipdev.io).
The description here has been paraphrased for clarity and adapted under fair use for educational and research purposes.

Please refer to [LICENSE.third_party.md](../LICENSE.third_party.md) for licensing information.

This quest is from [chipdev.io](https://chipdev.io/question/2).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/2>
