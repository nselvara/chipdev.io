[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)

# ChipDev.io Quest Solutions – in VHDL-2008

This repository contains synthesizable hardware design solutions for selected [ChipDev.io](https://chipdev.io/question-list) quests.  
Each solution is implemented in **VHDL-2008**, includes a testbench using [VUnit](https://vunit.github.io/) for automation, and can be simulated both locally and on [EDA Playground](https://edaplayground.com/).

These examples serve as a learning resource or starting point for building, simulating, and verifying digital designs in a structured way.

## 🔍 Quests Implemented

> All challenges are from [chipdev.io/question-list](https://chipdev.io/question-list)

1. **Simple Router**: Design a router that directs incoming data packets to one of several outputs based on a destination address.
2. **Second Largest Number**: Identify the second largest number among a group of unsigned inputs.
3. **Rounding Division**: Perform division and round the result to the nearest integer.
4. **Gray Code Counter**: Implement a counter that cycles through a Gray code sequence.
5. **Reversing Bits**: Reverse the bit order of a binary input word.
6. **Edge Detector**: Detect rising and falling edges in a digital input signal.
7. **PISO Shift Register**: Load data in parallel and shift it out serially.
8. **SIPO Shift Register**: Accept serial input and output the result in parallel.
9. **Fibonacci Generator**: Generate values from the Fibonacci sequence.
10. **Counting Ones**: Count the number of `1`s in an input vector.
11. **Gray to Binary Converter**: Convert Gray code to binary representation.
12. **Trailing Zeroes Counter**: Count the number of trailing zeroes in a binary number.
13. **One-Hot Detector**: Check if exactly one bit in the input is high.
14. **Stopwatch Timer**: Build a stopwatch with start, stop, and reset.
15. **Sequence Detector**: Detect a binary pattern using a finite state machine.
16. **Divisibility by 3 Checker**: Check if a binary number is divisible by 3.
17. **Divisibility by 5 Checker**: Check if a binary number is divisible by 5.
18. **Palindrome Detector**: Check if a binary number is a palindrome.
19. **Programmable Sequence Detector**: Detect user-defined binary sequences.
20. **Divide-by-Evens Clock Divider**: Divide input clock by even factors (2, 4, 6...).
21. **FizzBuzz**: Output "Fizz", "Buzz", or "FizzBuzz" based on number divisibility.
22. **Full Adder**: 1-bit full adder with carry in/out.
23. **Basic ALU**: Arithmetic Logic Unit with basic math and logic ops.
24. **Ripple Carry Adder**: Multi-bit adder using ripple carry architecture.
25. **Flip-Flop Array**: Store parallel data using D flip-flops.
26. **Multi-Bit FIFO**: Implement a First-In-First-Out queue.
27. **Dot Product Calculator**: Multiply and accumulate two vectors.
28. **Binary to Thermometer Decoder**: Convert binary to thermometer code.
29. **Thermometer Code Detector**: Validate thermometer coding.
30. **2-Read 1-Write Register File**: Register file with two read ports and one write port.

## Minimum System Requirements

- **OS**: (Anything that can run the following)
  * **IDE**:
    - [`VSCode latest`](https://code.visualstudio.com/download) with following plugins:
      - [`Python`](https://marketplace.visualstudio.com/items?itemName=ms-python.python) by Microsoft
      - [`Pylance`](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance) by Microsoft
      - [`Draw.io`](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio) by Henning Dieterichs
      - [`Draw.io Integration: WaveDrom plugin`](https://marketplace.visualstudio.com/items?itemName=nopeslide.vscode-drawio-plugin-wavedrom) by nopeslide
      - [`TerosHDL`](https://marketplace.visualstudio.com/items?itemName=teros-technology.teroshdl) by Teros Technology
      - [`VHDL-LS`](https://marketplace.visualstudio.com/items?itemName=hbohlin.vhdl-ls) by Henrik Bohlin (Deactivate the one provided by TerosHDL)
  * **VHDL Simulator**: (Anything that supports **VHDL-2008**):
  * **Script execution environment**:
    - `Python 3.11.4` to automatise testing via **VUnit**

## Initial Setup

### Clone repository

- Open terminal
- Run `git clone git@github.com:nselvara/"Project name".git`
- Run `cd "Project name"`
- Run `code .` to open VSCode in the current directory

### Create Virtual Environment in VSCode

#### Via GUI

- Open VSCode
- Press `CTRL + Shift + P`
- Search for `Python: Create Environment` command
- Select `Venv`
- Select the latest Python version
- Select [`requirements.txt`](./ip/requirements.txt) file
- Wait till it creates and activates it automatically

#### Via Terminal

- Open VSCode
- Press `CTRL + J` if it's **Windows** or ``CTRL+` `` for **Linux** to open the terminal
- Run `python -m venv .venv` in Windows Terminal (CMD) or `python3 -m venv .venv` in Linux Terminal
- Run `.\.venv\Scripts\activate` on Windows or `source .venv/bin/activate` on Linux
- Run `pip install -r requirements.txt` to install all of the dependencies
- Click on `Yes` when the prompt appears in the right bottom corner

#### Additonal Info

For more info see page: [Python environments in VS Code](https://code.visualstudio.com/docs/python/environments)

## Running simulation

### Environment variables

Make sure the environment variable for ModelSim or QuestaSim is set, if not:

**_:memo:_**: Don't forget to write the correct path to the ModelSim/QuestaSim folder

#### Linux

Open terminal and run either of the following commands:

**_:memo:_**: Don't forget to write `>>` instead of `>` if you want to append to the file else you will overwrite it.

```bash
echo "export VUNIT_MODELSIM_PATH=/opt/modelsim/modelsim_dlx/linuxpe" >> ~/.bashrc
# $questa_fe is the path to the folder where QuestaSim is installed, 
# as it doesn't have a default path, it's up to you where you install it
# Provide the path to the folder where QuestaSim is installed
echo "export VUNIT_MODELSIM_PATH=\"$questa_fe/21.4/questa_fe/win64/\"" >> ~/.bashrc
```

Then restart the terminal or run `source ~/.bashrc` command.

#### Windows

Open PowerShell and run either of the following commands:

```bat
setx /m VUNIT_MODELSIM_PATH C:\modelsim_dlx64_2020.4\win64pe\
setx /m VUNIT_MODELSIM_PATH C:\intelFPGA_pro\21.4\questa_fe\win64\
```

## Running simulation

### Option 1: EDA Playground (Web-Based)

You can simulate this project on [EDA Playground](https://www.edaplayground.com/) without installing anything locally. Use the following settings:

- **Testbench + Design**: `VHDL`
- **Top entity**: `tb_test_entity` (or whatever your testbench entity is called)
- ✅ **Enable `VUnit`** (required to use VUnit checks like `check_equal`)

  > ⚠️ Enabling **VUnit** will automatically create a `testbench.py` file.  
  > **Do not delete this file**, as it is required for:
  > - Initializing the VUnit test runner
  > - Loading `vunit_lib` correctly
  > - Enabling procedures such as `check_equal`, `check_true`, etc.

  > However, EDA Playground will **not create any VHDL testbench** for you.  
  > Therefore, you need to **manually create your own VHDL testbench file**:
  > - Click the ➕ symbol next to the file list
  > - Name it `tb.vhd` (or your own testbench name)
  > - Paste your testbench VHDL code into it

- ✅ Select `OSVVM` under Libraries if your testbench uses OSVVM features
- **Tools & Simulators**: `Aldec Riviera Pro 2022.04` or newer
- **Compile Options**: `-2008`
- ✅ Check `Open EPWave after run`
- ✅ Check `Use run.do Tcl file` or `Use run.bash shell script` for more control (optional)

These settings ensure compatibility with your VUnit-based testbenches and allow waveform viewing through EPWave.

### Option 2: Local ModelSim/QuestaSim

#### Environment variables

Make sure the environment variable for ModelSim or QuestaSim is set, if not:

**_:memo:_**: Don't forget to write the correct path to the ModelSim/QuestaSim folder

##### Linux

Open terminal and run either of the following commands:

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

### Run simulation locally

- Open VSCode
- Open [`run.py`](ip/run.py) file
- Files and/or folders that you don't want to simulate, write into `exclude_files` or `exclude_folders` list(s)
  - For example, if you don't want to simulate `tb_foo.vhd` file, write `"tb_foo.vhd"` into the list
- Set the file you want to simulate in the `tb_file_name` variable
  - If you want to simulate `tb_foo.vhd` file, set `tb_file_name` to `"tb_foo"`
  - If you want to simulate all testbenches, set `tb_file_name` to `""`
- Then just press the play button in the top right corner  
  **Or**
- Open terminal and run:

```bash
./.venv/Scripts/python.exe ./ip/run.py
```

- If the argument `enable_gui_simulation` in [run.py](ip/run.py) file was set to `true`, the simulation will open in the ModelSim/Questasim GUI
  - In GUI you can run the simulation by writing `vunit_restart` in the console
- If the argument `enable_gui_simulation` in [run.py](ip/run.py) file was set to `false`, the simulation will run in the terminal automatically

```python
vunit_project = create_vunit_project(
    clean=False,
    compile_only=False,
    enable_gui_simulation=False,
    selected_simulation="**"
)
```
