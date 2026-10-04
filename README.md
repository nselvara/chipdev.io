[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![VUnit Tests](https://github.com/nselvara/chipdev.io/workflows/VUnit%20Tests/badge.svg)](https://github.com/nselvara/chipdev.io/actions)
[![Tests](https://gist.githubusercontent.com/nselvara/cc050d27587b0722b2e41f143fa9e2d5/raw/badge.svg)](https://github.com/nselvara/chipdev.io/actions/workflows/vunit.yml)
[![GitHub Tag](https://img.shields.io/github/v/tag/nselvara/chipdev.io)](https://github.com/nselvara/chipdev.io/tags)

# ChipDev.io Quest Solutions – in VHDL-2008

> [!IMPORTANT]
> **📦 chipdev.io has been shut down.** The original website is unfortunately no longer available.
> This repository is therefore a **self-contained archive** of the quest solutions: every problem statement, testbench, and waveform diagram below works offline.
> The original pages are preserved via the [Wayback Machine](https://web.archive.org/web/*/https://chipdev.io/question-list) where available.
> However, the preserved URLs don't show any content as the JS code was rendered client-side and is not captured by the Wayback Machine.

This repository contains synthesizable hardware design solutions for selected [ChipDev.io](https://web.archive.org/web/*/https://chipdev.io/question-list) quests.
Each solution is implemented in **VHDL-2008**, includes a testbench using [VUnit](https://vunit.github.io/) for automation, and can be simulated both locally and on [EDA Playground](https://edaplayground.com/).
A `tb_xy_wave.do` file is also provided to preload signals and variables for convenient waveform inspection in ModelSim.

These examples serve as a learning resource or starting point for building, simulating, and verifying digital designs in a structured way.

## 🔍 Quests Implemented

> [!NOTE]
> All challenges are from [chipdev.io/question-list](https://web.archive.org/web/*/https://chipdev.io/question-list) *(site offline — archived link)*
> Each challenge is solved in **VHDL-2008** with **VUnit** testbenches
> *(Difficulty and companies shown for reference)*

> [!NOTE]
> Quest #27 is missing from the chipdev.io website's numbered sequence. In this repository, 28 is referred to as the 27th quest.

1. **Simple Router** – 🟢 Easy – 🏢 Apple, Nvidia
   - Design a router that directs packets to outputs based on destination.

2. **Second Largest** – 🟢 Easy – 🏢 Nvidia, Intel
   - Identify the second largest number from a set of inputs.

3. **Rounding Division** – 🟠 Medium – 🏢 Apple
   - Perform integer division and round the result.

4. **Gray Code Counter** – 🔴 Hard – 🏢 Google, Qualcomm
   - Implement a counter using Gray code sequence.

5. **Reversing Bits** – 🟢 Easy – 🏢 AMD, Broadcom
   - Reverse the bits of a binary input word.

6. **Edge Detector** – 🟢 Easy – 🏢 Nvidia, Tesla
   - Detect rising and falling edges on an input signal.

7. **Parallel-in, Serial-out Shift Register** – 🟢 Easy – 🏢 Tesla, Apple
   - Load data in parallel and shift it out serially.

8. **Serial-in, Parallel-out Shift Register** – 🟢 Easy – 🏢 Nvidia, AMD
   - Shift data in serially and output it in parallel.

9. **Fibonacci Generator** – 🟢 Easy – 🏢 Cadence, Synopsys
   - Generate numbers in the Fibonacci sequence.

10. **Counting Ones** – 🟢 Easy – 🏢 Microsoft, ARM
    - Count the number of 1’s in a binary vector.

11. **Gray Code to Binary** – 🟠 Medium – 🏢 Google, Synopsys
    - Convert Gray code to binary representation.

12. **Trailing Zeroes** – 🟢 Easy – 🏢 Tesla, Microsoft
    - Count trailing 0s in a binary number.

13. **One-Hot Detector** – 🟢 Easy – 🏢 Broadcom
    - Check if exactly one bit is set.

14. **Stopwatch Timer** – 🟢 Easy – 🏢 Intel, Cadence
    - Create a stopwatch with start/stop/reset.

15. **Sequence Detector** – 🟢 Easy – 🏢 Apple, AMD
    - FSM to detect a specific binary pattern.

16. **Divisible by 3** – 🟠 Medium – 🏢 Google, Broadcom
    - Check divisibility by 3 using binary logic.

17. **Divisible by 5** – 🟠 Medium – 🏢 Nvidia, Cadence
    - Check divisibility by 5 using binary logic.

18. **Palindrome Detector** – 🟢 Easy – 🏢 Tesla, Synopsys
    - Determine if a binary string is a palindrome.

19. **Programmable Sequence Detector** – 🟠 Medium – 🏢 AMD, ARM
    - Detect a binary pattern defined at runtime.

20. **Divide-by-Evens Clock Divider** – 🟢 Easy – 🏢 Intel, ARM
    - Clock divider that supports even divisors only.

21. **FizzBuzz** – 🟢 Easy – 🏢 Intel, Broadcom
    - Hardware implementation of the FizzBuzz game.

22. **Full Adder** – 🟢 Easy – 🏢 Tesla, AMD
    - 1-bit full adder with carry-in and carry-out.

23. **Basic ALU (Intro to Verilog)** – 🟢 Easy – 🏢 Microsoft
    - Simple ALU supporting arithmetic and logic ops.

24. **Ripple Carry Adder** – 🟠 Medium – 🏢 Nvidia, Cadence
    - Multi-bit adder using ripple carry full adders.

25. **Flip-Flop Array** – 🟠 Medium – 🏢 Apple, AMD
    - Array of D flip-flops for holding data.

26. **Multi-Bit FIFO** – 🔴 Hard – 🏢 Tesla, Synopsys
    - FIFO with multi-bit enqueue/dequeue logic.

27. **Dot Product** – 🟠 Medium – 🏢 Intel, Qualcomm
    - Compute the dot product of two binary vectors.

28. **Binary to Thermometer Decoder** – 🟢 Easy – 🏢 Intel, Cadence
    - Convert binary input to thermometer code.

29. **Thermometer Code Detector** – 🟢 Easy – 🏢 Google, Cadence
    - Check if input follows thermometer encoding.

30. **2-Read 1-Write Register File** – 🔴 Hard – 🏢 Tesla, AMD
    - Register file with two read ports and one write port.

31. **Configurable 8-Bit LFSR** – 🟠 Medium – 🏢 Google, Synopsys
    - LFSR with selectable seed and tap positions.

32. **Carry-Select Adder** – 🟠 Medium – 🏢 Intel, ARM
    - Adder optimized using carry-select structure.

33. **Bubble Sort** – 🟠 Medium – 🏢 Tesla, Google
    - Sort a vector of values using bubble sort.

34. **Mealy Finite State Machine (FSM)** – 🟢 Easy – 🏢 Google, Microsoft
    - FSM where outputs depend on both current state and input.

## Implementation Notes

> [!NOTE]
> **Deviations from ChipDev.io Specifications**
>
> This repository makes two consistent changes across all implementations:
>
> 1. **Reset signal naming**: ChipDev.io uses various names (`resetn`, `reset_n`, `reset`). This repository uniformly uses **`rst_n`** for consistency.
>
> 2. **Generic parameters**: Some quests specify hardcoded bit widths. This repository adds **`DATA_WIDTH`** and similar generic parameters where appropriate to improve reusability.
>
> Some signal names from the original problems (e.g., port naming conventions) may not be optimal but were preserved to maintain alignment with the source material. Quest-specific deviations are documented in individual README files.

## Testbench Methodology

> [!NOTE]
> **Professional Verification Approach**
>
> All testbenches follow industry-standard practices:
>
> - **VUnit framework**: Automated test execution with pass/fail reporting
> - **OSVVM RandomPkg**: Constrained-random stimulus generation for better coverage than sequential patterns
> - **Dual verification**: Checker procedures use different coding styles than the DUT to avoid systematic errors
> - **Edge case testing**: Explicit tests for boundary conditions, resets, and corner cases
> - **ModelSim .do files**: Pre-configured waveform views for debugging
>
> Test strategies typically include:
>
> 1. **Directed tests**: Exhaustive testing of all valid states/combinations
> 2. **Random tests**: Hundreds of randomized inputs to catch unexpected corner cases
> 3. **Reset testing**: Verify proper initialization and reset behavior

## Waveform Diagrams

Since chipdev.io is offline, each quest's README embeds a reconstructed timing diagram built from the entity's ports and the example tests in its testbench.

Every quest folder contains a [`waveforms/`](ip/) subfolder with:

- `waveform.json` – [WaveDrom](https://wavedrom.com/) source reconstructed from the entity ports and the testbench's directed tests
- `waveform.svg` – rendered diagram, embedded in the quest's README

> [!WARNING]
> **Accuracy disclaimer:** The reconstructed waveforms went through careful checking, but they **can contain mistakes**. For authoritative verification, refer to the testbench examples and other tests — those were checked with considerably more scrutiny. If a waveform disagrees with a testbench, trust the testbench.

> [!NOTE]
> **Why WaveDrom and not Mermaid?** Mermaid has no timing/waveform diagram type, so it cannot render clocked waveforms with data buses. WaveDrom JSON is rendered to SVG with [`wavedrom-cli`](https://github.com/wavedrom/wavedrom-cli) (requires **Node.js**).

To re-render a diagram after editing its JSON (run from inside the quest folder):

```bash
npx wavedrom-cli -i waveforms/waveform.json -s waveforms/waveform.svg
```

The `waveform.json` files can also be previewed and edited live in VS Code with the [`Waveform Render`](https://marketplace.visualstudio.com/items?itemName=bmpenuelas.waveform-render) extension (`bmpenuelas.waveform-render`).

## Minimum System Requirements

- **OS**: (Anything that can run the following)
  - **IDE**:
    - [`VSCode latest`](https://code.visualstudio.com/download) with following plugins:
      - [`Python`](https://marketplace.visualstudio.com/items?itemName=ms-python.python) by Microsoft
      - [`Pylance`](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance) by Microsoft
      - [`Draw.io`](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio) by Henning Dieterichs
      - [`Draw.io Integration: WaveDrom plugin`](https://marketplace.visualstudio.com/items?itemName=nopeslide.vscode-drawio-plugin-wavedrom) by nopeslide
      - [`Waveform Render`](https://marketplace.visualstudio.com/items?itemName=bmpenuelas.waveform-render) by bmpenuelas (preview/edit the `waveform.json` files used for the waveform diagrams)
      - [`TerosHDL`](https://marketplace.visualstudio.com/items?itemName=teros-technology.teroshdl) by Teros Technology
      - [`VHDL-LS`](https://marketplace.visualstudio.com/items?itemName=hbohlin.vhdl-ls) by Henrik Bohlin (Deactivate the one provided by TerosHDL)
  - **VHDL Simulator**: (Anything that supports **VHDL-2008**):
  - **Script execution environment**:
    - `Python 3.11.4` to automatise testing via **VUnit**

## Initial Setup

### Clone repository

- Open terminal
- Run `git clone git@github.com:nselvara/chipdev.io.git`
- Run `cd "Project name"`
- Run `git submodule update --init --recursive` to initialise and update submodules
- Run `code .` to open VSCode in the current directory

### Install Dependencies

- Open a terminal in the project directory
- Run `pip install -r ip/requirements.txt` to install all dependencies

## Running simulation

### Option 1: EDA Playground (Web-Based)

You can simulate this project on [EDA Playground](https://www.edaplayground.com/) without installing anything locally. Use the following settings:

- **Testbench + Design**: `VHDL`
- **Top entity**: `tb_test_entity` (or whatever your testbench entity is called)
- ✅ **Enable `VUnit`** (required to use VUnit checks like `check_equal`)

> [!WARNING]
> Enabling **VUnit** will automatically create a `testbench.py` file.
> **Do not delete this file**, as it is required for:
>
> - Initializing the VUnit test runner
> - Loading `vunit_lib` correctly
> - Enabling procedures such as `check_equal`, `check_true`, etc.

> [!WARNING]
> However, EDA Playground will **not create any VHDL testbench** for you.
> Therefore, you need to **manually create your own VHDL testbench file**:
>
> - Click the ➕ symbol next to the file list
> - Name it `tb.vhd` (or your own testbench name)
>   - Paste your testbench VHDL code into it

- ✅ Select `OSVVM` under Libraries if your testbench uses OSVVM features
- **Tools & Simulators**: `Aldec Riviera Pro 2022.04` or newer
- **Compile Options**: `-2008`
- ✅ Check `Open EPWave after run`
- ✅ Check `Use run.do Tcl file` or `Use run.bash shell script` for more control (optional)

These settings ensure compatibility with your VUnit-based testbenches and allow waveform viewing through EPWave.

### Option 2: Local ModelSim/QuestaSim

#### Environment variables

Make sure the environment variable for ModelSim or QuestaSim is set, if not:

> [!Important]
> Don't forget to write the correct path to the ModelSim/QuestaSim folder

##### Linux

Open terminal and run either of the following commands:

> [!Caution]
> Don't forget to write `>>` instead of `>` if you want to append to the file else you

```bash
echo "export VUNIT_MODELSIM_PATH=/opt/modelsim/modelsim_dlx/linuxpe" >> ~/.bashrc
# $questa_fe is the path to the folder where QuestaSim is installed
echo "export VUNIT_MODELSIM_PATH=\"$questa_fe/21.4/questa_fe/win64/\"" >> ~/.bashrc
```

Then restart the terminal or run `source ~/.bashrc` command.

#### Windows

Open PowerShell and run either of the following commands:

```bat
setx /m VUNIT_MODELSIM_PATH C:\modelsim_dlx64_2020.4\win64pe\
setx /m VUNIT_MODELSIM_PATH C:\intelFPGA_pro\21.4\questa_fe\win64\
```

### Run Simulation Locally

This project uses **VUnit** for automated VHDL testbench simulation.
The script [`test_runner.py`](ip/test_runner.py) acts as a wrapper, so you don’t need to deal with VUnit internals.

#### ⚙️ How to Run

1. **Open a terminal** in the project directory.
2. To run **all testbenches**, simply execute:

   ```bash
   python ip/test_runner.py
   ```

##### What the script does

- Uses `run_all_testbenches_lib` internally.
  - This hides the VUnit implementation
- Looks for testbenches in the `./ip/` folder.
- Runs all files matching `tb_*.vhd` (recursive pattern `**`).
- GUI can be enabled via `gui=True` in `test_runner.py`.

##### Optional Customisation

You can change the following arguments in `test_runner.py`:

```python
run_all_testbenches_lib(
    path="./ip/",                 # Path where the HDL & tb files are located
    tb_pattern="**",              # Match all testbenches
    timeout_ms=1.0,               # Timeout in milliseconds
    gui=False,                    # Set to True to open ModelSim/QuestaSim GUI
    compile_only=False,           # Only compile, don’t run simulations
    clean=False,                  # Clean before building
    debug=False,                  # Enable debug logging
    use_xilinx_libs=False,        # Add Xilinx simulation libraries
    use_intel_altera_libs=False,  # Add Intel/Altera simulation libraries
    excluded_list=[],             # List of testbenches to exclude
    xunit_xml="./test/res.xml"    # Output file for test results
)
```

## License

All VHDL source code, testbenches, and scripts in this repository are licensed under the GNU General Public License v3.0 (GPLv3).
See the [LICENSE](./LICENSE) file for full details.

> [!NOTE]
> Problem statements and task descriptions referenced from [chipdev.io](https://chipdev.io) are **not** part of this license.
> They are © chipdev.io and are used under fair use for educational purposes only.
> This repository is not affiliated with or endorsed by chipdev.io.
> This file and the accompanying VHDL code are licensed under GPLv3.

> [!NOTE]
> See [LICENSE-THIRD-PARTY](./LICENSE-THIRD-PARTY.md) for more.
