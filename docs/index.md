---
hide:
  - toc
---
## Nastran Compatible Finite Elements (CoFE) 
Nastran Compatible Finite Elements (CoFE) is a finite element solver for structural analysis and optimization. CoFE is an open-source program implemented using object-oriented MATLAB.

### How CoFE Works
CoFE reads Nastran-format text input files and writes Nastran-format HDF5 output files. Model and solution data are also output as a MATLAB workspace variable. A simple MATLAB command executes the solve. 

<img src="https://raw.githubusercontent.com/vtpasquale/web_assets/assets/img/inputOutput.svg" width="750">

CoFE is **NOT** a wrapper for Nastran. It is an independent solver that clones a subset of commercial-Nastran capabilities.

### Documentation
CoFE is primarily documented at this repository's [*Wiki Page*](https://github.com/vtpasquale/NASTRAN_CoFE/wiki). All CoFE input entry formats are documented in the [*CoFE Quick Reference Guide*](https://github.com/vtpasquale/NASTRAN_CoFE/wiki/Quick-Reference-Guide). CoFE supports a subset of commercial-Nastran input data, and some CoFE-supported input entries have reduced functionality. Users who are unfamiliar with finite element analysis and/or Nastran should review a commercial-Nastran [*Getting Started User's Guide*](https://www.google.com/search?q=Nastran+Getting+Started+User%E2%80%99s+Guide). 

### Pre/Post Processing
Because the input format is Nastran-compatible, preprocessors intended for Nastran can be used to prepare CoFE models. There are too many preprocessor options to list them all, but examples include PATRAN, Femap, and Gmsh. CoFE writes MSC Nastran-format HDF5 output files (other commercial Nastran versions have independent HDF5 output formats with incompatible schemas). MSC HDF5 format can be postprocessed using PATRAN. Femap support for MSC HDF5 format is in-work according to [developers]( https://community.sw.siemens.com/s/question/0D54O000061xpmj/femap-needs-to-better-support-msc-nastrans-newer-features-feature-requests). 
