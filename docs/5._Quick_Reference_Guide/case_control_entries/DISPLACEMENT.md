---
hide:
  - toc
---
# DISPLACEMENT
Requests displacement output.

## Format
`DISPLACEMENT([PRINT,PLOT])={ALL,n,NONE}`

## Examples
`DISPLACEMENT=6`

`DISPLACEMENT(PRINT)=ALL`

`DISPLACEMENT(SORT2, PUNCH, REAL)=ALL`


## Describers
| Type       | Meaning  |
| ---------- | -------- |
| PRINT      | Disk output to text and HDF5 (default).            |
| PLOT       | Disk output to HDF5 only.                          |
| ALL        | Output for all points.                             |
| n          | Output only for the points listed by SET n.        |
| NONE       | Do not output at any points.                       |

## Remarks
1. Only the requested results are provided in CoFE solution data.
2. Results are passed to the workspace in native CoFE format.
3. Disk output is also controlled by the `writeOutput2Disk` argument and `PARAM,PLOT` bulk data input.
4. See [Output Data](../../../3._User_Guide/Output_Data) for additional details. 
