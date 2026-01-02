# Quest 9 – Fibonacci Generator

## Original Problem Statement

### Prompt

Design a circuit which generates the Fibonacci sequence starting with `1` and `1` as the first two numbers.

The Fibonacci sequence is a sequence of numbers where each number is the sum of the two previous numbers. More formally this can be expressed as:

`F₀ = 1`
`F₁ = 1`
`Fₙ = Fₙ₋₁ + Fₙ₋₂ for n > 1`.

Following the definition of the Fibonacci sequence above we can see that the sequence is `1, 1, 2, 3, 5, 8, 13, etc`.

The sequence should be produced when the active low signal (`resetn`) becomes active. In other words, the sequence should restart from `1` followed by another `1` (the Fibonacci sequence's initial condition) as soon as `resetn` becomes active.

### Input and Output Signals

- `clk` - Clock signal
- `resetn` - Synchronous reset-low signal
- `out` - Current Fibonacci number

### Output signals during reset

- `out` - `1` when `resetn` is active (the first `1` of the Fibonacci sequence)

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/9>

> [!NOTE]
> **Implementation Deviation**
>
> This implementation adds a `DATA_WIDTH` generic parameter for configurability and overflow handling, though the original problem doesn't specify a particular bit width.

## Description

Fibonacci sequence generator using a 2-element pipeline holding the previous two values.
Each clock cycle computes `sum = fib[1] + fib[0]`, then shifts the pipeline left, discarding the oldest value and inserting the new sum.
The pipeline initialises to `[1, 1]` and produces the sequence 1, 1, 2, 3, 5, 8, 13...

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/9).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/9>
