---
hide:
  - toc
---
Model parameter used for output control. 

## Format

| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| MDLPRM   | PARAM1   | VAL1     |          |          |          |          |          |          |          | 

## Example
`MDLPRM,HDF5,0`

## Fields

| Describer    | Contents                                       |
| ------------ | ---------------------------------------------- |
| PARAM1       | Name of the parameter. Must be `HDF5`. (char)  |
| VAL1         | Value of the parameter. (Integer >= -1)              |

## Remarks:
1.  HDF5 parameter value options: 
    - `-1` Do not create HDF5 output file. (default)
    - `>-1` Create HDF5 output file.
2.  This CoFE entry is only compatible with MSC Nastran (not other commercial versions).
3.  CoFE writes only results data (not input data) to the HDF5 output file. 