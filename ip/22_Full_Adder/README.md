# Quest 22 – Full Adder

## Original Problem Statement

### Prompt

Design a Full Adder (FA)—the most important building block for digital computation.

A FA is a fully combinational circuit that adds three single-bit inputs `a`, `b`, and `cin` (carry-in). Inputs `a` and `b` are the two operands whereas `cin` represents the overflow bit carried forward from a previous addition stage.

The FA circuit has two single-bit outputs, `sum` and `cout`—the later represents the overflow bit to be used as a carry-in to a subsequent addition stage.

### Input and Output Signals

`a` - First operand input bit
`b` - Second operand input bit
`cin` - Carry-in input bit from a previous adder stage
`sum` - Sum output bit
`cout` - Carry-out (overflow) output bit to be propagated to the next addition stage

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/22>

## Description

Full adder with two architectural implementations.
The gate-level version uses the canonical equations: `sum = a XOR b XOR cin` and `cout = (a AND b) OR (b AND cin) OR (cin AND a)`.
The operator-based version performs unsigned addition across three separate 2-bit additions with carry propagation.

## Source

This quest is from [chipdev.io](https://chipdev.io/question/22).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/22>
