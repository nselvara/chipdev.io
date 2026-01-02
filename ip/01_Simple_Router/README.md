# Quest 1 - Simple Router

## Original Problem Statement

### Prompt

Build a router circuit which forwards data from the input (din) to one of four outputs (dout0, dout1, dout2, or dout3), specified by the address input (addr).

The address is a two bit value whose decimal representation determines which output value to use. Append to dout the decimal representation of addr to get the output signal name. For example, if addr=b11 then the decimal representation of addr is 3, so the output signal name is dout3.

The input has an enable signal (din_en), which allows the input to be forwarded to an output when enabled. If an output is not currently being driven to, then it should be set to 0.

### Input and Output Signals

- `din` - Input data
- `din_en` - Enable signal for din. Forwards data from input to an output if 1, does not forward data otherwise
- `addr` - Two bit destination address. For example addr = b11 = 3 indicates din should be forwarded to output value 3 (dout3)
- `dout0` - Output 0. Corresponds to addr = b00
- `dout1` - Output 1. Corresponds to addr = b01
- `dout2` - Output 2. Corresponds to addr = b10
- `dout3` - Output 3. Corresponds to addr = b11

> [!NOTE]
> For the complete problem description, please visit:
> <https://chipdev.io/question/1>

## Description

Combinational router using a `case` statement to decode the 2-bit address and route input data to one of four outputs.
All outputs default to zero, then the selected output is conditionally assigned when `din_en` is high.
Synthesises to a simple 4:1 demultiplexer with AND gates gating the enable signal.

---

## Source

This quest is from [chipdev.io](https://chipdev.io/question/1).

The problem description above is used under fair use for educational purposes.
For licensing information, see [LICENSE-THIRD-PARTY.md](../../LICENSE-THIRD-PARTY.md).

**Webarchive link:** <https://web.archive.org/web/https://chipdev.io/question/1>
