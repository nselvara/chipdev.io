# Quest 28 – Binary to Thermometer Decoder

## Original Problem Statement

### Prompt

Thermometer (a.k.a. unary) coding is frequently used in digital systems applications to represent a natural number. In a thermometer code, a `N`-bit binary number is represented by a `(2 ** N)`-bit digital word, which has `m` zeros followed by `(N - m)` ones or vice-versa.

In this question, implement a binary to thermometer decoder circuit using Verilog. The input, `din`, is an 8-bit unsigned binary word, and the output `dout` is the thermometer code representation of the input at any time. The output is 256-bit long; `dout` has `m` zeros followed by `(256 - m)` ones.

### Input and Output Signals

- `din` - Binary, unsigned input word
- `dout` - Thermometer output word

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/29>
>
> Note: This is Quest 28 in the repository (chipdev.io is missing Quest #27)

> [!NOTE]
> **Implementation Deviation**
>
> The original problem specifies an 8-bit input and 256-bit output. This implementation adds a `THERMOMETER_WIDTH` generic parameter, making the design configurable for different thermometer code widths.

## Description

Binary-to-thermometer code decoder that sets all bits from 0 to the binary input value.
A loop iterates through all output positions, setting each bit if its index is less than or equal to the binary input.
For example, input 5 produces output 0b00111111 (six ones).
The loop-based approach synthesises despite the non-constant range because it evaluates all possibilities at compile time.

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/29).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/29>
