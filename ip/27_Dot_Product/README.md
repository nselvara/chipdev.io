# Quest 27 – Dot Product

## Original Problem Statement

### Prompt

In this question, implement a module that produces the dot product (scalar product) of two equal-length, single dimensional vectors, `A = [a₁, a₂, a₃]` and `B = [b₁, b₂, b₃]`. The module has one 8-bit port, `din`, that is used for entering the input sequences of numbers. It also has two outputs, `run`, and `dout`, which return computation status and dot product of the inputs, respectively.

Assume the sequence is read in the following order: a1, a2, a3, b1, b2, b3. A counter can be used to keep track of the sequence of numbers. Once the 6th number has been registered, output `run` is asserted, and output `dout` returns a scalar 18-b unsigned number corresponding to the dot product of the inputs. In the next cycles, `run` is de-asserted whereas `dout` sustains its previous valid value til the next six numbers of input vectors `A` and `B` are entered. At any rising edge of `clk`, if `resetn` is logic low, then zero is written to the module's internal registers. When `resetn` transitions back from zero to one, `run` is asserted and `dout` is produces zero as `A · B = 0`.

### Input and Output Signals

`din` - 8-bit unsigned data input word
`clk` - Clock signal
`resetn` - Synchronous, active low, reset signal
`dout` - Output word corresponding to a dot b operation
`run` - Single-bit output signal to indicate a new dot product operation

### Output signals during reset

`dout` - 0
`run` - 1

> [!NOTE]
> Quest 27 doesn't exist on chipdev.io. This repository's Quest 27 corresponds to chipdev.io Question 28.
> For the complete problem description, please visit:
> <https://chipdev.io/question/28>
>
> Note: This is Quest 27 in the repository (chipdev.io is missing Quest #27, so this uses their Quest 28)

> [!NOTE]
> **Implementation Deviation**
>
> The original problem specifies an 8-bit `din` input, 3-element vectors, and 18-bit `dout` output. This implementation adds `DATA_WIDTH` and `VECTOR_SIZE` generic parameters, making the design configurable for different bit widths and vector sizes.

## Description

Sequential dot-product calculator receiving vector elements one at a time.
Accumulates `VECTOR_SIZE * 2` inputs into an array (first `VECTOR_SIZE` elements are vector A, next `VECTOR_SIZE` are vector B), then computes the sum of element-wise products using an impure function.
The `run_out` signal pulses high for one cycle when the calculation completes.
Output width accounts for multiplication growth (`2 * DATA_WIDTH`) plus accumulation growth (`log2(VECTOR_SIZE)`).

## Source

This quest is from [chipdev.io](https://chipdev.io/question/28).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/28>
