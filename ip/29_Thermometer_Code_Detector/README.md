# Quest 29 – Thermometer Code Detector

## Original Problem Statement

### Prompt

Thermometer (a.k.a. unary) coding is frequently used in digital systems applications to represent a natural number. In a thermometer code, a `N`-bit binary number is represented by a `(2 ** N)`-bit digital word, which has `m` zeros followed by `(N - m)` ones or vice-versa.

Implement a thermometer code detector. The module has two ports, `codeIn` and `isThermemeter`. The former is a `DATA_WIDTH`-bit unsigned binary word, and the latter is the signal that indicates whether or not the input is a thermometer code. The circuit must support both types of thermometer representations. For instance, for an input word that is `N`-bit long, the detector must detect thermometer representations that use `m` zeros followed by `(N - m)` ones or `m` ones followed by `(N - m)` zeros. Output `isThermemeter` is one when a thermometer word is detected at the input and zero otherwise.

### Input and Output Signals

`codeIn` - Thermometer input word
`isThermometer` - Output bit that indicates whether or not an input word is a thermometer code

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/30>
>
> Note: This is Quest 29 in the repository (chipdev.io is missing Quest #27)

## Description

Thermometer code validator ensuring the input contains contiguous ones from LSB.
The function checks that bit 0 is set (LSB must be 1), allows all-ones as valid, then counts bit transitions.
Valid thermometer codes have exactly one transition (from 1 to 0). Early-exit optimisation stops counting after detecting more than one transition.

## Source

This quest is from [chipdev.io](https://chipdev.io/question/30).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/30>
