[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)

# Project name

Describe your project

The VHDL codes are tested with [VUnit framework's](https://vunit.github.io/) checks, [OSVVM](https://osvvm.org/) random features and simulated with [ModelSim](https://en.wikipedia.org/wiki/ModelSim).

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

### Run simulation

- Open VSCode
- Open [run.py](ip/run.py) file
- Files and/or folders that you don't want to simulate, write into `exclude_files` resp. `exclude_folders` list(s)
  - For example, if you don't want to simulate `tb_foo.vhd` file, write `"tb_foo.vhd"` into the list
- Set the file you want to simulate in the `tb_file_name` variable
  - If you want to simulate `tb_foo.vhd` file, set `tb_file_name` to `"tb_foo"`
  - If you want to simulate all testbenches, set `tb_file_name` to `""`
- Then just press on Play button in the top right corner </br> Or
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

