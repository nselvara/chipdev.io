# -*- coding: utf-8 -*-
"""
@author: N. Selvarajah
"""

from vunit import VUnit, VUnitCLI
from os import walk, getenv
from os.path import dirname, join

def main():
    file_directory = dirname(__file__)

    # Select the testbench to run
    # tb_file_name (tb_xy.vhd) => "tb_xy"
    # If all the testbenches are to be run, use tb_file_name = "**"
    tb_file_name = "**"
    try:
        wave_file_name = tb_file_name.split('.')[0]
    except ValueError:
        wave_file_name = tb_file_name
    wave_file_name = ''.join(("wave_", wave_file_name , ".do"))

    vunit_project = create_vunit_project(
        clean=False,
        compile_only=False,
        debug=False,
        enable_gui_simulation=False,
        selected_simulation=tb_file_name
    )

    vunit_library = vunit_project.add_library('vunit_library')
    add_files_to_library(vunit_library=vunit_library, directory=file_directory)

    # Add timeout
    default_simulation_timeout_in_ms = 0.5
    vunit_project.set_generic(
        name='SIMULATION_TIMEOUT_IN_MS', value=str(default_simulation_timeout_in_ms), allow_empty=True
    )

    # Add modelsim simulation options
    simulation_option = []
    simulation_option += ["-L unisim"]  # add the library unisim needed for the simulation
    simulation_option += ["-L unisims_ver"]  # add the library unisim needed for the simulation
    simulation_option += ["-L xpm"]
    simulation_option += ["-t 1ns"]  # simulation resolution
    simulation_option += ["-voptargs=+acc"]  # enable signal tracing, needed for modelsim
    vunit_project.set_sim_option("modelsim.vsim_flags", simulation_option)

    # Disable StdArithNoWarnings & NumericStdNoWarnings
    vunit_project.set_sim_option("disable_ieee_warnings", True)

    # Add file to initialize the simulation when running on gui mode
    vunit_project.set_sim_option("modelsim.init_file.gui", wave_file_name, allow_empty=True)

    # Start simulation
    vunit_project.main()


def create_vunit_project(clean=False, compile_only=False, debug=False, enable_gui_simulation=True, selected_simulation="*"):
    # Get input argv but discard the first (current file name)
    # Note: this was the only way to create args that worked on every situation, do NOT change!
    import sys
    args = sys.argv.copy()
    args = args[1:]
    args.append("-p 1")  # number of tests to run in parallel
    args.append(selected_simulation)

    if clean:
        args.append('--clean')
    if compile_only:
        args.append('--compile')
    if enable_gui_simulation:
        args.append('--gui')
    if debug:
        args.append('--log-level=debug')

    vunit_project = VUnit.from_argv(argv=args, compile_builtins=False, vhdl_standard='2008')
    vunit_project.add_vhdl_builtins()
    vunit_project.add_osvvm()
    # vunit_project.enable_check_preprocessing() # Enable check_relation's boolean expression preprocessed for asserting
    return vunit_project


def add_files_to_library(vunit_library, directory):
    """ Add hdl files in the given directory (and subdirectory) to the vunit_library. """
    files = get_hdl_files_as_list(directory)
    files = return_pruned_list(files, '~')
    vunit_library.add_source_files(files, allow_empty=True)


def get_hdl_files_as_list(dir_name):
    """ Return list of hdl files in the given directory (including subdirectories). """
    # return get_files_by_extension(dir_name=dir_name, extensions=(".v", ".vhd", ".vhdl"))
    return get_files_by_extension(dir_name=dir_name, extensions=(".vhd", ".vhdl"))


def get_files_by_extension(dir_name: str, extensions):
    """ Return files in directory and subdirectories with the given extensions. """
    files = [join(root, file) for root, dirs, files in walk(dir_name) for file in files if file.endswith(extensions)]
    return files


def return_pruned_list(original_list: list[str], pattern_to_prune: str):
    """ Return a new list without the elements containing the specified pattern_to_prune. """
    file_list = [x for x in original_list if pattern_to_prune not in x]
    return file_list


if __name__ == '__main__':
    main()
