[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)

# ChipDev.io Quest Solutions – in VHDL-2008

This repository contains synthesizable hardware design solutions for selected [ChipDev.io](https://chipdev.io/question-list) quests.  
Each solution is implemented in **VHDL-2008**, includes a testbench using [VUnit](https://vunit.github.io/) for automation, and can be simulated both locally and on [EDA Playground](https://edaplayground.com/).

These examples serve as a learning resource or starting point for building, simulating, and verifying digital designs in a structured way.

## 🔍 Quests Implemented

> All challenges are from [chipdev.io/question-list](https://chipdev.io/question-list)
> Each challenge is solved in **VHDL-2008** with **VUnit** testbenches  
> *(Difficulty and companies shown for reference)*

1. **Simple Router** – 🟢 Easy – 🏢 Apple, Nvidia  
   Design a router that directs packets to outputs based on destination.

2. **Second Largest** – 🟢 Easy – 🏢 Nvidia, Intel  
   Identify the second largest number from a set of inputs.

3. **Rounding Division** – 🟠 Medium – 🏢 Apple  
   Perform integer division and round the result.

4. **Gray Code Counter** – 🔴 Hard – 🏢 Google, Qualcomm  
   Implement a counter using Gray code sequence.

5. **Reversing Bits** – 🟢 Easy – 🏢 AMD, Broadcom  
   Reverse the bits of a binary input word.

6. **Edge Detector** – 🟢 Easy – 🏢 Nvidia, Tesla  
   Detect rising and falling edges on an input signal.

7. **Parallel-in, Serial-out Shift Register** – 🟢 Easy – 🏢 Tesla, Apple  
   Load data in parallel and shift it out serially.

8. **Serial-in, Parallel-out Shift Register** – 🟢 Easy – 🏢 Nvidia, AMD  
   Shift data in serially and output it in parallel.

9. **Fibonacci Generator** – 🟢 Easy – 🏢 Cadence, Synopsys  
   Generate numbers in the Fibonacci sequence.

10. **Counting Ones** – 🟢 Easy – 🏢 Microsoft, ARM  
    Count the number of 1’s in a binary vector.

11. **Gray Code to Binary** – 🟠 Medium – 🏢 Google, Synopsys  
    Convert Gray code to binary representation.

12. **Trailing Zeroes** – 🟢 Easy – 🏢 Tesla, Microsoft  
    Count trailing 0s in a binary number.

13. **One-Hot Detector** – 🟢 Easy – 🏢 Broadcom  
    Check if exactly one bit is set.

14. **Stopwatch Timer** – 🟢 Easy – 🏢 Intel, Cadence  
    Create a stopwatch with start/stop/reset.

15. **Sequence Detector** – 🟢 Easy – 🏢 Apple, AMD  
    FSM to detect a specific binary pattern.

16. **Divisible by 3** – 🟠 Medium – 🏢 Google, Broadcom  
    Check divisibility by 3 using binary logic.

17. **Divisible by 5** – 🟠 Medium – 🏢 Nvidia, Cadence  
    Check divisibility by 5 using binary logic.

18. **Palindrome Detector** – 🟢 Easy – 🏢 Tesla, Synopsys  
    Determine if a binary string is a palindrome.

19. **Programmable Sequence Detector** – 🟠 Medium – 🏢 AMD, ARM  
    Detect a binary pattern defined at runtime.

20. **Divide-by-Evens Clock Divider** – 🟢 Easy – 🏢 Intel, ARM  
    Clock divider that supports even divisors only.

21. **FizzBuzz** – 🟢 Easy – 🏢 Intel, Broadcom  
    Hardware implementation of the FizzBuzz game.

22. **Full Adder** – 🟢 Easy – 🏢 Tesla, AMD  
    1-bit full adder with carry-in and carry-out.

23. **Basic ALU (Intro to Verilog)** – 🟢 Easy – 🏢 Microsoft  
    Simple ALU supporting arithmetic and logic ops.

24. **Ripple Carry Adder** – 🟠 Medium – 🏢 Nvidia, Cadence  
    Multi-bit adder using ripple carry full adders.

25. **Flip-Flop Array** – 🟠 Medium – 🏢 Apple, AMD  
    Array of D flip-flops for holding data.

26. **Multi-Bit FIFO** – 🔴 Hard – 🏢 Tesla, Synopsys  
    FIFO with multi-bit enqueue/dequeue logic.

27. **Dot Product** – 🟠 Medium – 🏢 Intel, Qualcomm  
    Compute the dot product of two binary vectors.

28. **Binary to Thermometer Decoder** – 🟢 Easy – 🏢 Intel, Cadence  
    Convert binary input to thermometer code.

29. **Thermometer Code Detector** – 🟢 Easy – 🏢 Google, Cadence  
    Check if input follows thermometer encoding.

30. **2-Read 1-Write Register File** – 🔴 Hard – 🏢 Tesla, AMD  
    Register file with two read ports and one write port.

31. **Configurable 8-Bit LFSR** – 🟠 Medium – 🏢 Google, Synopsys  
    LFSR with selectable seed and tap positions.

32. **Carry-Select Adder** – 🟠 Medium – 🏢 Intel, ARM  
    Adder optimized using carry-select structure.

33. **Bubble Sort** – 🟠 Medium – 🏢 Tesla, Google  
    Sort a vector of values using bubble sort.

34. **Mealy Finite State Machine (FSM)** – 🟢 Easy – 🏢 Google, Microsoft  
    FSM where outputs depend on both current state and input.

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
