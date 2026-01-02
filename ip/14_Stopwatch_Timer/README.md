# Quest 14 – Stopwatch Timer

## Original Problem Statement

### Prompt

Build a module which controls a stopwatch timer.

The timer starts counting when the start button (`start`) is pressed (pulses) and increases by `1` every clock cycle. When the stop button (`stop`) is pressed, the timer stops counting. When the reset button (`reset`) is pressed, the count resets to `0` and the timer stops counting.

If count ever reaches `MAX`, then it restarts from `0` on the next cycle.

`stop`'s functionality takes priority over `start`'s functionality, and `reset`'s functionality takes priority over both `stop` and `start`'s functionality.

### Input and Output Signals

- `clk` - Clock signal
- `reset` - Synchronous reset signal
- `start` - Start signal
- `stop` - Stop signal
- `count` - Current count

### Output signals during reset

- `count` - `0` when `reset` is active

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/14>

## Description

Stopwatch counter that starts/stops via control signals and counts from `0 to MAX`.
The `start_reg` variable latches the start condition, continuing the count until `stop_in` resets it.
When the counter reaches MAX, it wraps to zero.
The start signal acts as a sticky enable - once asserted, counting continues autonomously until explicitly stopped.

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/14).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/14>
