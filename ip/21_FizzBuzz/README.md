# Quest 21 – FizzBuzz

## Original Problem Statement

### Prompt

Design a circuit that counts incrementally for a maximum number of cycles, `MAX_CYCLES`. At all cycles, the circuit should determine whether or not the counter value is evenly divisible by parameters `FIZZ`, `BUZZ`, or both.

The counter value should monotonically increase when the reset signal (`resetn`) is de-asserted. The counter sequence is expected to start from 0 and be `MAX_CYCLES` long, restarting from 0 when `MAX_CYCLES` is reached (e.g. for `MAX_CYCLES = 100: 0, 1, 2, 3, ..., 99, 0, 1, ...`).

As the circuit counts, output `fizz` should be asserted if the current counter value is evenly divisible by `FIZZ`. `buzz` should output 1 when the current counter value is divisible by `BUZZ`. Finally, output `fizzbuzz` should be 1 when counter is evenly divisible by both `FIZZ` and `BUZZ`.

### Input and Output Signals

`clk` - Clock signal
`resetn` - Synchronous, active low, reset signal
`fizz` - Output Fizz
`buzz` - Output Buzz
`fizzbuzz` - Output FizzBuzz

### Output signals during reset

`fizz` - 1
`buzz` - 1
`fizzbuzz` - 1

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/21>

## Description

Hardware FizzBuzz counter with independent modulo counters for fizz (mod 3) and buzz (mod 5).
Each counter increments independently and wraps when reaching its maximum.
The `fizz` and `buzz` outputs pulse high when their respective counters wrap.
`fizzbuzz` is the logical AND of both, pulsing when divisible by both 3 and 5 (i.e., divisible by 15).
A master `cycle_count` resets all counters after `MAX_CYCLES`.

## Source

This quest is from [chipdev.io](https://chipdev.io/question/21).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/21>
