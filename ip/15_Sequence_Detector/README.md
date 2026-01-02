# Quest 15 – Sequence Detector

## Original Problem Statement

### Prompt

Given a stream of input bits, pulse a `1` on the output (`dout`) whenever a `b1010` sequence is detected on the input (`din`).

When the reset-low signal (`resetn`) goes active, all previously seen bits on the input are no longer considered when searching for `b1010`.

### Input and Output Signals

- `clk` - Clock signal
- `resetn` - Synchronous reset-low signal
- `din` - Input bits
- `dout` - `1` if a `b1010` was detected, `0` otherwise

### Output signals during reset

- `dout` - `0` when `resetn` is active

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/15>

## Description

Parameterizable sequence detector using a shift register matched against a constant pattern.
Each clock shifts the serial input `din` into the register, with the code handling both ascending and descending bit orderings via compile-time selection.
Detection pulses high when the shift register contents exactly match `SEQUENCE_PATTERN`.

### State Diagram (for pattern "1010")

```mermaid
stateDiagram-v2
    [*] --> IDLE: reset

    IDLE --> SAW_1: din=1
    IDLE --> IDLE: din=0

    SAW_1 --> SAW_10: din=0
    SAW_1 --> SAW_1: din=1

    SAW_10 --> SAW_101: din=1
    SAW_10 --> IDLE: din=0

    SAW_101 --> DETECTED: din=0<br/>dout=1 ✓
    SAW_101 --> SAW_1: din=1

    DETECTED --> SAW_10: din=0
    DETECTED --> SAW_1: din=1

    note right of IDLE
        shift_reg = xxxx
        No match yet
    end note

    note right of SAW_1
        shift_reg = xxx1
        Partial match: "1"
    end note

    note right of SAW_10
        shift_reg = xx10
        Partial match: "10"
    end note

    note right of SAW_101
        shift_reg = x101
        Partial match: "101"
    end note

    note right of DETECTED
        shift_reg = 1010
        FULL MATCH!
        dout pulses high
    end note
```

**Implementation:** Shift register continuously shifts `din` in, comparator checks if register equals `SEQUENCE_PATTERN` ("1010").

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/15).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/15>
