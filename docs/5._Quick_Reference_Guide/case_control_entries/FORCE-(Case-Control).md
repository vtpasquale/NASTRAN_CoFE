---
hide:
  - toc
---
# FORCE
Requests element force output.

## Format
`FORCE(LHSD)={ALL,n,NONE}`

## Examples
`FORCE=6`

`FORCE(PRINT)=ALL`

`FORCE(SORT2, PUNCH, REAL)=ALL`


## Describers
| Type       | Meaning  |
| ---------- | -------- |
| LHSD       | Left hand side describers. These are ignored.      |
| ALL        | Output for all elements.                           |
| n          | Output only for the elements listed by SET n.      |
| NONE       | Do not output at any elements .                    |

## Remarks
1. Only the requested results are provided in CoFE solution data.
2. Results are passed to the workspace in native CoFE format.
3. Results are written to hard disk in HDF5 format by default; this can be controlled by the MDLPRM bulk data entry.
4. The PRINT describer is read and tracked internally, but print output is unsupported. 
