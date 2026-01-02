# Quest 19 – Programmable Sequence Detector

## Original Problem Statement

### Prompt

Given a stream of input bits, pulse a `1` on the output (`seen`) whenever a specified 5-bit target sequence is detected on the input (`din`). The target sequence is specified by `init` and is updated whenever the reset-low signal (`resetn`) is deasserted.

The target sequence is always a 5-bit value, so left-padded `0`'s are also considered part of the sequence (a sequence specified as `b11` would actually be `b00011`).

When `resetn` goes active, all previously seen bits on the input are no longer considered when searching for the target sequence.

### Input and Output Signals

`clk` - Clock signal
`resetn` - Synchronous reset-low signal
`init` - Target sequence to detect. Updated whenever `resetn` is asserted
`din` - Input bits
`seen` - `1` if the sequence specified by `init` was detected, `0` otherwise

### Output signals during reset

`seen` - `0` when `resetn` is active

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/19>

## Description

Run-time programmable sequence detector that captures the target pattern from `init` during reset.
A shift register accumulates incoming bits while `din_count` tracks how many bits have been received.
The `seen` output asserts only after exactly `DATA_WIDTH` bits have been collected and the shift register matches the programmed pattern.

## Source

This quest is from [chipdev.io](https://chipdev.io/question/19).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/19>
