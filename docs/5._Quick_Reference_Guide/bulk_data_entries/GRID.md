---
hide:
  - toc
---
# GRID
Defines the location of a node, the directions of its displacement, and its permanent single-point constraints.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| GRID     | ID       | CP       | X1       | X2       | X3       | CD       | PS       | _SEID_   |          |

## Fields
| Field      | Contents |
| ---------- | -------- |
| ID | Grid point identification number. (Integer > 0) |
| CP | Identification number of coordinate system in which the location of the grid point is defined. (Integer ≥ 0 or blank*) |
| X1, X2, X3 | Location of the grid point in coordinate system CP. (Real; Default = 0.0) |
| CD | Identification number of coordinate system in which the displacements, degrees-of-freedom, constraints, and solution vectors are defined at the grid point. (Integer ≥ 0 or blank *) |
| PS | Permanent single-point constraints associated with the grid point. (Any of the Integers 1 through 6 with no embedded blanks, or blank*.) |
|  _SEID_ | Not used. |
* See the GRDSET entry for default options for the CP, CD, and PS, fields.
