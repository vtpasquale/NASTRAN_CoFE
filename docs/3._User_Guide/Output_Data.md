# Output Data
Output data control is consistent with commercial Nastran. The user controls the forms of output, the output response types, and the sets of elements or nodes for which data are provided. The response types and entity sets can be subcase-specific. 

## Response type and response set control
Response type and response set control are consistent with commercial Nastran. Case control inputs are used to specify the response types and response sets to be output. Node response types are [DISPLACEMENT](../../5._Quick_Reference_Guide/case_control_entries/DISPLACEMENT)
and 
[SPCFORCES]( ../../5._Quick_Reference_Guide/case_control_entries/SPCFORCES). 
Element response types are
[FORCE]( ../../5._Quick_Reference_Guide/case_control_entries/FORCE-(Case-Control)),
[STRESS]( ../../5._Quick_Reference_Guide/case_control_entries/STRESS),
[STRAIN]( ../../5._Quick_Reference_Guide/case_control_entries/STRAIN),
[ESE]( ../../5._Quick_Reference_Guide/case_control_entries/ESE), and
[EKE]( ../../5._Quick_Reference_Guide/case_control_entries/EKE).

Only requested response types are recovered. For example, specifying
```
DISPLACEMENT = ALL
``` 
Will result in the output of displacement results for all nodes. Subcase-specific control is allowed. 
The 
[SET]( ../../5._Quick_Reference_Guide/case_control_entries/SET) case control input can be used to specify the nodes or elements for which output data will be provided. For example, specifying
```
SET 101 = 4,6,8
DISPLACEMENT = 101
```
Will result in the output of displacement results for nodes 4, 6, and 8 only. 

Abbreviated case control entries will be unrecognized and ignored. For example, **entering DISP rather than DISPLACEMENT, or SPCFORCE rather than SPCFORCES will result in the request being ignored.** Left-hand-side describers provide further control on the form of the output, which will be discussed in the following subsections.

## Output data forms
Three forms of output data are available:

* Native output -> to the MATLAB workspace
* Text output
* HDF5 output (MSC format)

Native output is the best form if the data are to be processed using MATLAB (e.g., optimization). Text output is designed for human readability (similar to commercial Nastran .f06). HDF5 output can be read by MSC Patran for postprocessing (and potentially other commercial postprocessors); it can also be easily read with the help of publicly available libraries. 

## Native output
Native output is stored in a workspace variable that is first output argument from `Cofe.m`. 
```
out = Cofe(‘example.dat’)
```

Here `out` is an object that contains both the model and solution data:
```
out =  Cofe with properties:
       model: [1×1 Model]
    solution: [2×1 StaticsSolution]
```
Native output is always provided when the first output argument is specified. Response types and response sets will be consistent with case control inputs.

## Text output
Text output is written by default. Response type and response sets will be consistent with case control inputs. Text output can be suppressed by setting the `Cofe.m` parameter `writeOutput2Disk` to `false`.
```
out = Cofe(‘example.dat’,'writeOutput2Disk',false)
```
The  `writeOutput2Disk` parameter is forced to `false` anytime the first `Cofe.m` input parameter is not type `char`. For example, in optimization cases the user may provide a `BdfEntries` object rather than specify an input file.

## HDF5 output
HDF5 output is written when the `Cofe.m` parameter `writeOutput2Disk` is `true` (default) and when 
the bulk data ‘PARAM,POST’ value is set to `<1` (the default value is `1`). For example, set
```
PARAM,POST,-1
```
Response type and response sets will be consistent with case control inputs.

## Left-hand-side describers
Case control left-hand-side describers (LHSD) control if response types will be written text output or not. Native output and HDF5 output are not impacted by LHSD. LHSD options are blank, `PRINT`, and `POST`. Other LHSD will be ignored. 
Specifying `POST` will result in text output suppression for that response type. For example, with `writeOutput2Disk` set to `true`, `PARAM,POST` set to `<1`, and
```
FORCE = ALL
STRESS(PRINT) = ALL
STRAIN(POST) = ALL
```
force and stress results will be output to native, text, and HDF5. Strain results will be output to native and HDF5 only.



