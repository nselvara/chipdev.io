# Quest 4 - Gray Code Counter

## Original Problem Statement

### Prompt

Build a circuit that generates a Gray code sequence starting from 0 on the output (dout).

Gray code is an ordering of binary numbers such that two successive values only have one bit difference between them. For example, a Gray code sequence for a two bit value could be:

b00
b01
b11
b10

The Gray code sequence should use the standard encoding. In the standard encoding the least significant bit follows a repetitive pattern of 2 on, 2 off ( ... 11001100 ... ); the next digit a pattern of 4 on, 4 off ( ... 1111000011110000 ... ); the nth least significant bit a pattern of 2n on 2n off.

When the reset-low signal (resetn) goes to 0, the Gray code sequence should restart from 0.

### Input and Output Signals

`clk` - Clock signal
`resetn` - Synchronous reset-low signal
`out` - Gray code counter value

### Output signals during reset

`out` - 0 when resetn is active

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/4>

## Description

Combinational bit-reversal circuit using a loop that maps `dout(i) <= din(din'high - i)` to mirror the input vector.
Synthesises to pure wiring with no logic gates required.

## Source

This quest is from [chipdev.io](https://chipdev.io/question/4).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/4>
