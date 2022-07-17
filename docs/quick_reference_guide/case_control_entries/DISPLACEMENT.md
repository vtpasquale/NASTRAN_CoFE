---
hide:
  - toc
---
Requests displacement output.

## Format
`DISPLACEMENT(LHSD)={ALL,n,NONE}`

## Examples
`DISPLACEMENT=6`

`DISPLACEMENT(PRINT)=ALL`

`DISPLACEMENT(SORT2, PUNCH, REAL)=ALL`


## Describers
| Type       | Meaning  |
| ---------- | -------- |
| LHSD       | Left hand side describers. These are ignored.      |
| ALL        | Output for all points.                             |
| n          | Output only for the points listed by SET n.        |
| NONE       | Do not output at any points.                       |

## Remarks
1. Only the requested results are provided in CoFE solution data.
2. Results are passed to the workspace in native CoFE format.
3. Results are written to hard disk in HDF5 format by default; this can be controlled by the MDLPRM bulk data entry.
4. The PRINT describer is read and tracked internally, but print output is unsupported. 