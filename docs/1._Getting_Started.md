CoFE’s only dependency is [MATLAB](https://www.mathworks.com/products/matlab.html). There is nothing else to install – you just run it within MATLAB.

## Step 1. Acquire and Install MATLAB
[MATLAB](https://www.mathworks.com/products/matlab.html) can be acquired from [MathWorks](https://www.mathworks.com/). It comes with a platform-specific installer.

## Step 2. Acquire CoFE
CoFE source files can be acquired from GitHub by either cloning the repository or by downloading source as a zip file. The following Git command will clone the repository:

`git clone https://github.com/vtpasquale/NASTRAN_CoFE.git`

Alternatively, navigate to the CoFE [GitHub page](https://github.com/vtpasquale/NASTRAN_CoFE), click on the green *Code* button and select *Download Zip*. Then unzip the files where you want them. The contents of the cloned repository should resemble:

```
.
├─ docs/
├─ examples/
├─ nastran_cofe/
├─ testing/
├─ LICENSE.txt
├─ README.md
└─ mkdocs.yml
```

## Step 3. Run CoFE

Launch MATLAB. Set your current folder to the 72-bar truss analysis example:
```
.
└─ examples/
   └─ 0001_72_bar_truss_analysis/
```
Open and run `runAnalysis.m`.

