# Quest 3 - Rounding Division

## Original Problem Statement

### Prompt

Divide an input number by a power of two and round the result to the nearest integer. The power of two is calculated using 2^DIV_LOG2 where DIV_LOG2 is a module parameter. Remainders of 0.5 or greater should be rounded up to the nearest integer. If the output were to overflow, then the result should be saturated instead.

### Input and Output Signals

`din` - Input number
`dout` - Rounded result

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/3>

## Description

Divider that performs power-of-2 division with rounding.
The division is accomplished via right-shift by `DIV_LOG2` positions.
The rounding logic examines the bit at position `DIV_LOG2-1` (representing the 0.5 threshold) - if this bit is set, it adds 1 to the quotient.
The `resize()` function handles saturation when the result overflows the output width.

## Source

This quest is from [chipdev.io](https://chipdev.io/question/3).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/3>
