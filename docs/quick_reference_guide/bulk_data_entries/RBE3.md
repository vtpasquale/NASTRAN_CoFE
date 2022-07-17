Defines the motion at a reference grid point as the weighted average of the motions at a set of other grid points.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| RBE3 | EID |  | REFGRID | REFC | WT1 | C1 | G1,1 | G1,2
| | G1,3 | G1,4 | G1,5 | -etc.- |  | 

## Fields
| Field      | Contents |
| ---------- | -------- |
| EID | Element identification number. (Integer > 0) |
| REFGRID | Reference grid point identification number. (Integer > 0) |
| REFC | Component numbers at the reference grid point. (Any of the integers 1 through 6 with no embedded blanks.) |
| WT1 | Relative weighting factor for components of motion on the following entry at grid points G1,j. This value does not affect the solution because the user is limited to a single relative weighting factor. (Real) |
| C1 | Component numbers with weighting factor WT1 at grid points G1,j. (Any of the integers 1 through 6 with no embedded blanks.) |
| G1,j | Grid points with components C1 that have weighting factor WT1 in the averaging equations. (Integer > 0) |

## Remarks
1. It is recommended that for most applications only the translation components 123 be used for C1. An exception is the case where the G1,j are colinear. A rotation component may then be added to stabilize its associated rigid body mode for the element.
