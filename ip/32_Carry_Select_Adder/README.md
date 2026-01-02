# Quest 32 – Carry-Select Adder

## Original Problem Statement

### Prompt

Use the solutions to questions 22 & 24 (Full Adder and Ripper Carry Adder, respectively) to implement a 24-bit Carry Select Adder (CSA). CSAs commonly employ two Ripple Carry Adders (RCAs) which compute `a + b + cin`, where `cin = 0` in one computation, and `cin = 1` in the other. The final result is obtained by selecting the correct partial sum, based on the `cout` bit of the previous stage.

In this question, implement a 24-bit Carry Select Adder (CSA) using multiple parallel RCAs and multiplexers. The CSA module takes two unsigned integers `a` and `b`, and produces an output word `sum`, corresponding to `a + b` operation. The number of RCA stages in the CSA can be chosen by the designer, e.g., 3 stages of 8-bit RCAs, 4 stages of 6-bit RCAs, etc. Bonus: Can you design a parametric number of stage 24-bit CSA? Test your design with various number of RCA stages.

### Input and Output Signals

- `a` - First operand input word
- `b` - Second operand input word
- `result` - Output word corresponding to a plus b operation (25-bit word since both a and b are 24-bit)

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/33>
>
> Note: This is Quest 32 in the repository (chipdev.io is missing Quest #27)

## Description

Carry-select adder dividing the operands into `STAGES` blocks plus an optional remainder stage.
Each stage instantiates two ripple-carry adders computing results for both carry-in possibilities (0 and 1).
A multiplexer chain selects the correct sum based on the actual carry from the previous stage.
When `DATA_WIDTH` doesn't divide evenly by `STAGES`, remaining bits form an additional stage.
This architecture trades area for reduced carry propagation delay compared to pure ripple-carry.

### Architecture Diagram

```mermaid
flowchart TD
    subgraph "Stage 0 (bits 0-7)"
        a0[a 7:0] --> RCA0_0[RCA<br/>cin=0]
        b0[b 7:0] --> RCA0_0
        a0 --> RCA0_1[RCA<br/>cin=1]
        b0 --> RCA0_1

        RCA0_0 --> sum0_0[sum if cin=0]
        RCA0_1 --> sum0_1[sum if cin=1]
        RCA0_0 --> c0_0[cout if cin=0]
        RCA0_1 --> c0_1[cout if cin=1]

        sum0_0 --> MUX0[MUX]
        sum0_1 --> MUX0
        zero[cin=0] --> MUX0
        MUX0 --> result0[result 7:0]

        c0_0 --> CMUX0[Carry<br/>MUX]
        c0_1 --> CMUX0
        zero --> CMUX0
        CMUX0 --> carry0[carry to<br/>stage 1]
    end

    subgraph "Stage 1 (bits 8-15)"
        a1[a 15:8] --> RCA1_0[RCA<br/>cin=0]
        b1[b 15:8] --> RCA1_0
        a1 --> RCA1_1[RCA<br/>cin=1]
        b1 --> RCA1_1

        RCA1_0 --> sum1_0[sum if cin=0]
        RCA1_1 --> sum1_1[sum if cin=1]

        sum1_0 --> MUX1[MUX]
        sum1_1 --> MUX1
        carry0 --> MUX1
        MUX1 --> result1[result 15:8]

        RCA1_0 --> CMUX1[Carry<br/>MUX]
        RCA1_1 --> CMUX1
        carry0 --> CMUX1
        CMUX1 --> carry1[carry to<br/>stage 2]
    end

    subgraph "Stage 2 (bits 16-23)"
        direction LR
        dots[... similar structure ...]
    end

    carry1 --> dots
    dots --> finalCarry[Final Carry]

    style RCA0_0 fill:#e1f5ff
    style RCA0_1 fill:#e1f5ff
    style RCA1_0 fill:#e1f5ff
    style RCA1_1 fill:#e1f5ff
    style MUX0 fill:#fff4e1
    style MUX1 fill:#fff4e1
```

**Key Advantage:** Stages compute in parallel, then quickly select correct result based on previous carry.
**Critical Path:** One RCA delay + (STAGES × MUX delay) vs. full ripple of DATA_WIDTH stages.

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/33).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/33>
