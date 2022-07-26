---
hide:
  - toc
---
## Nastran Compatible Finite Elements (CoFE) 
Nastran Compatible Finite Elements (CoFE) is a finite element solver for structural analysis and optimization. CoFE is an open-source program implemented using object-oriented MATLAB.

### How CoFE Works
The process flow is illustrated here:
<p align="center">
<img src="https://raw.githubusercontent.com/vtpasquale/web_assets/assets/img/inputOutput2.svg" width="500">
</p>

CoFE reads inputs from a Nastran-format input file, solves the specified analysis cases, creates a MATLAB workspace variable containing model and solution data, writes a human-readable text output file, and optionally writes an MSC Nastran-format HDF5 output file.

CoFE is **NOT** a wrapper for Nastran. It is an independent solver that clones a subset of commercial-Nastran capabilities.

### Running CoFE
A single MATLAB command executes the solve. For example:
```
out = Cofe('example.dat');
```
where `example.dat` is a Nastran-format input file and `out` is model and solution data computed by CoFE. 

### Documentation
CoFE's documentation [website](https://vtpasquale.github.io/NASTRAN_CoFE/) is automatically generated from source files in the [/docs](https://github.com/vtpasquale/NASTRAN_CoFE/tree/version5/docs) directory. All CoFE input entry formats are documented in the [*Quick Reference Guide*](https://vtpasquale.github.io/NASTRAN_CoFE/quick_reference_guide/quick_reference_guide/) section of the website. CoFE supports a subset of commercial-Nastran input data, and some CoFE-supported input entries have reduced functionality. Users who are unfamiliar with finite element analysis or Nastran should review a commercial-Nastran [*Getting Started User's Guide*](https://www.google.com/search?q=Nastran+Getting+Started+User%E2%80%99s+Guide). 

### Pre/Post Processing
Because the input format is Nastran-compatible, preprocessors intended for Nastran can be used to prepare CoFE models. There are too many preprocessor options to list them all, but examples include PATRAN, Femap, and Gmsh. CoFE writes MSC Nastran-format HDF5 output files (other commercial Nastran versions have independent HDF5 output formats with incompatible schemas). MSC HDF5 format can be postprocessed using PATRAN. Femap support for MSC HDF5 format is in-work according to [developers]( https://community.sw.siemens.com/s/question/0D54O000061xpmj/femap-needs-to-better-support-msc-nastrans-newer-features-feature-requests). 