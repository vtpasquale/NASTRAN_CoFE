## CoFE Version 4 
This branch contains CoFE v4, which is a legacy CoFE version that is no longer in development. CoFE v4 models are defined using NASTRAN-formatted input files (bulk data section only). Case control and optimization inputs are defined using MATLAB. Examples are provided to illustrate the process of creating analysis and optimization cases. A simple GUI is provided for previewing model inputs and viewing analysis results.  A CoFE v4.0 web user manual is maintained on the [_gh-pages_](https://github.com/vtpasquale/NASTRAN_CoFE/tree/gh-pages) branch of this repository.

CoFE development continues in the [version5](https://github.com/vtpasquale/NASTRAN_CoFE/tree/version5) branch of this repository. Version 5 is a complete rewrite that includes a reshaped program architecture and new features that include:
* Rectangular, cylindrical, and spherical coordinate system support for both node definition and nodal displacement reference frames
* New element types
* Input file processing that includes Nastran executive and case control sections
* Simplified source code organization through 
    * Improved object composition using
        * heterogeneous object arrays
        * hierarchical object interfacing
    * Restructured class responsibilities by separating classes used for 
        * input processing
        * model definition
        * analysis solutions
        * results data
