# Reconfigurable-Adders

This repository includes the source code, the implementation results and the automation scripts used for the Diploma Thesis

**Designing Reconfigurable Approximate Arithmetic Architecture on FPGA**

## Implementation_Results

The collected data includes over 1500 adder variants for accurate, approximate and partially reconfigured designs.
The data is provided as plain .csv files and as .xlsx files including filtering and sorting options and charts for selected adder variants.

## Scripts

The scripts folder contains bash and tcl scripts for the implementation and test automation of the approximate adder designs.
To use those scripts, copy all source files from the [Approximate designs folder](VHDL_source_files/Approximate_Adders/) and the [Scripts folder](Scripts/) into one folder.
Open the "approx_adder_generator_complete.sh" to adjust the desired adder designs and bit widths. (testing designs with bit widths greater than 8 bit is not recommended due to very large time and hard disk requirements)
Additional information about each script can be found in the respective files.

## VHDL_source_files

Each source code folder contains the source files for the respective design type (accurate, approximate, partially reconfigured).
The recommended software for project creation and implementation is Vivado 17.1 or later.
The [Partially Reconfigured Adder folder](VHDL_source_files/Reconfig_Adders/) is already set up with an existing Vivado project. Therefore, it is only required to open the "Reconfig_Adders.xpr" Vivado project file.

