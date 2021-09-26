## Nastran Compatible Finite Elements (CoFE) 
Nastran Compatible Finite Elements (CoFE) is a finite element solver for structural analysis and optimization. CoFE is an open-source program implemented using object-oriented MATLAB.

### How CoFE Works
CoFE reads Nastran-format text input files and writes Nastran-format HDF5 output files. Model and solution data are also output as a MATLAB workspace variable. A simple MATLAB command executes the solve. 

<img src="https://raw.githubusercontent.com/vtpasquale/web_assets/assets/img/inputOutput.svg" width="750">

CoFE is **NOT** a wrapper for Nastran. It is an independent solver that clones a subset of commercial-Nastran capabilities.

### Benefits of Nastran Compatibility
The main benefits of Nastran compatibility are:
- Preprocessors are available to process the input. There are too many to list them all, but examples include PATRAN, Femap, and Gmsh.
- Postprocessors are available to process the output. CoFE writes MSC Nastran-format HDF5 output files (other versions of Nastran have independent HDF5 output formats with completely different schemas). MSC HDF5 format can be postprocessed using PATRAN. No other postprocessor works with MSC HDF5 format, but the Femap development working to support this format.
- Streamlined verification by input/output comparison.

### Intended Use
CoFE is developed for education and research; it’s not intended to be a replacement for commercial Nastran solvers.  CoFE’s functionality and source code are intended to be useful for (1) students learning the finite element method or design optimization, and (2) researchers who are developing new analysis or optimization methods.
