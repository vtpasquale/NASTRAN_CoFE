---
hide:
  - toc
---
# STRESS
Requests element stress output.

## Format
`STRESS([PRINT,POST])={ALL,n,NONE}`

## Examples
`STRESS=6`

`STRESS(PRINT)=ALL`

`STRESS(SORT2, PUNCH, REAL)=ALL`


## Describers
| Type       | Meaning  |
| ---------- | -------- |
| PRINT      | Disk output to text and HDF5 (default).            |
| POST       | Disk output to HDF5 only.                          |
| ALL        | Output for all elements.                           |
| n          | Output only for the elements listed in SET n.      |
| NONE       | Do not output at any elements .                    |

## Remarks
1. Only the requested results are provided in CoFE solution data.
2. Results are passed to the workspace in native CoFE format.
3. Disk output is also controlled by the `writeOutput2Disk` argument and `PARAM,POST` bulk data input.
4. See [Output Data](../../../3._User_Guide/Output_Data) for additional details. 
