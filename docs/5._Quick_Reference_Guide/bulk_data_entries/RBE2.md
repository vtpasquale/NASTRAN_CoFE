---
hide:
  - toc
---
# RBE2
Defines a rigid body with independent degrees-of-freedom that are specified at a single grid point and with dependent degrees-of-freedom that are specified at an arbitrary number of grid points.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| RBE2 | EID | GN | CM | GM1 | GM2 | GM3 | GM4 | GM5 |
| | GM6 | GM7 | GM8 | -etc.- |


## Fields
| Field      | Contents |
| ---------- | -------- |
| EID | Element identification number. (Integer > 0)
| GN | Identification number of grid point to which all six independent degrees-of freedom for the element are assigned. (Integer > 0)
| CM | Component numbers of the dependent degrees-of-freedom in the global coordinate system at grid points GMi. (Integers 1 through 6 with no embedded blanks.)
| GMi | Grid point identification numbers at which dependent degrees-of-freedom are assigned. (Integer > 0)
