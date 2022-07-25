---
hide:
  - toc
---
# ESE
Requests element strain energy output.

## Format
`ESE([PRINT,POST])={ALL,n,NONE}`

## Examples
`ESE=6`

`ESE(PRINT)=ALL`

`ESE(SORT2, PUNCH, REAL)=ALL`


## Describers
| Type       | Meaning  |
| ---------- | -------- |
| PRINT      | Disk output to text and HDF5 (default).            |
| POST       | Disk output to HDF5 only.                          |
| ALL        | Output for all elements.                           |
| n          | Output only for the elements listed by SET n.      |
| NONE       | Do not output at any elements .                    |

## Remarks
1. Only the requested results are provided in CoFE solution data.
2. Results are passed to the workspace in native CoFE format.
3. Disk output is also controlled by the `writeOutput2Disk` argument and `PARAM,POST` bulk data input.
4. See [Output Data](../../../3._User_Guide/Output_Data) for additional details. 
5. There is no threshold applied to suppresses output for elements having low energy values.
6. Energy, energy percent, and energy density are all output. 
