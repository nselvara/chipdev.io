# Quest 31 – Configurable LFSR

## Original Problem Statement

### Prompt

A Linear-Feedback Shift Register (LFSR) is a type a of shift-register that can generate a pseudo-random stream of binary words. The shift-register is configured in a ring fashion. A feedback loop is created by XOR-ing the ouputs of specific stages (also known as taps) of the shift-register and connecting them to the input of its first stage.

In this question, implement a LFSR that can produce a pseudorandom sequence of `DATA_WIDTH`-bit output words. The inputs to the module are `din`, which is the initial value written to the shift-register upon reset, `tap`, which is a `DATA_WIDTH`-bit word corresponding to the feedback polynomial to the LFSR, and `resetn`, which resets the shift-register. In a Fibonacci LFSR with 16 stages, `tap = 16'b1011_0100_0000_0000` because the XOR inputs are coming from outputs of stages 16, 14, 13, and 11. That is, the position of the one bits in tap determines the inputs to the XOR tree. Assume the input tap is buffered/registered inside the module.

### Input and Output Signals

- `clk` - Clock signal
- `resetn` - Synchronous, active low, reset signal
- `din` - Input data (initial data input value, e.g. 8'b0000_0001)
- `tap` - Input tap (feedback polynomial, e.g. 8'b1011_0101)
- `dout` - Output data

### Output signals during reset

- `dout` - 1

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/32>
>
> Note: This is Quest 31 in the repository (chipdev.io is missing Quest #27)

## Description

Configurable Linear Feedback Shift Register with runtime-programmable tap positions.
The `tap` input specifies which bit positions contribute to the feedback calculation.
Each clock cycle computes the feedback bit as the XOR reduction of all tapped positions (`xor(tap_reg and shift_reg)`), then shifts this feedback into the LSB.
The tap configuration and seed value are captured during reset.

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/32).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/32>
