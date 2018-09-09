<img src="https://raw.githubusercontent.com/vtpasquale/cofeV5docs/gh-pages/assets/images/nastranCofeLogo.png" width="550">

NASTRAN Compatible Finite Elements (CoFE) is a standalone finite element code for structural analysis and design. CoFE is an open source program implemented using object-oriented MATLAB.

## CoFE Version 4 
CoFE v4.0 is the latest stable version. This version occupies the current ([_master_](https://github.com/vtpasquale/NASTRAN_CoFE) branch and is archived as release  [_v4.0_](https://github.com/vtpasquale/NASTRAN_CoFE/releases/tag/v4.0)).

CoFE v4.0 models are defined using NASTRAN-formatted input files (bulk data section only). Case control and optimization inputs are defined using MATLAB. Examples are provided to illustrate the straightforward process of creating analysis and optimization cases. A simple GUI is provided for previewing model inputs and viewing analysis results. 

A CoFE v4.0 web user manual is maintained on the [_gh-pages_](https://github.com/vtpasquale/NASTRAN_CoFE/tree/gh-pages) branch of this repository and can be reviewed [here](http://vtpasquale.github.io/NASTRAN_CoFE/).

## CoFE Version 5
CoFE v5.0 is currently under development and occupies the [version5](https://github.com/vtpasquale/NASTRAN_CoFE/tree/version5) branch of this repository. This version completely reshapes the program architecture to allow for the sustainable addition of several new features that include
* Rectangular, cylindrical, and spherical coordinate system support for both node definition and nodal displacement reference frames
* Simplified source code organization through 
    * Improved object composition using
        * heterogeneous object arrays
        * hierarchical object interfacing
    * Restructured class responsibilities by separating classes used for 
        * input processing
        * model definition
        * analysis solutions
        * postprocessing

Significant v5.0 development progress has been accomplished; however, CoFE v4.0 is recommended for any user analysis at this time. 
