---
hide:
  - toc
---
# SPC1
Defines a set of single-point constraints.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| SPC1 | SID | C | G1 | G2 | G3 | G4 | G5 | G6 |  
| | G7 | G8 | G9 | G10 | G11 | -etc.-  |   |   |  


## Fields
| Field      | Contents |
| ---------- | -------- |
| SID | Identification number of single-point constraint set. (Integer > 0)
| C   | Component numbers. (Any unique combination of the Integers 1 through 6 with no embedded blanks for grid points. This number must be Integer 0 or blank for scalar points.)
| Gi  | Grid or scalar point identification numbers. (Integer > 0 or `THRU`; For `THRU` option, G1 < G2.)
