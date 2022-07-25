---
hide:
  - toc
---
# GRDSET
Defines default options for fields 3, 7, and 8, of all GRID entries.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| GRDSET   |          | CP       |          |          |          | CD       | PS       | _SEID_   |          |

## Fields
| Field      | Contents |
| ---------- | -------- |
| CP | Identification number of coordinate system in which the location of the grid points are defined. (Integer ≥ 0 or blank) |
| CD | Identification number of coordinate system in which the displacements, degrees-of-freedom, constraints, and solution vectors of the grid point are defined. (Integer ≥ -1 or blank) |
| PS | Permanent single-point constraints on the grid point. (Any combination of Integers 1 through 6 with no embedded blanks, or blank.) |
|  _SEID_ | Not used. |


