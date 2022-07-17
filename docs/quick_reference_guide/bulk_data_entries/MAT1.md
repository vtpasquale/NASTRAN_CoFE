---
hide:
  - toc
---
Defines linear isotropic material properties.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| MAT1 | MID | E | G | NU | RHO | _A_ | _TREF_ | _GE_ |

## Fields
| Field      | Contents |
| ---------- | -------- |
| MID | Material identification number.  (Integer > 0) |
| E | Young’s modulus. (Real ≥ 0.0 or blank) |
| G | Shear modulus. (Real ≥ 0.0 or blank) |
| NU | Poisson’s ratio. (-1.0 < Real ≤ 0.5 or blank) |
| RHO | Mass density. (Real) |
| _A_ | Not used. |
| _TREF_ | Not used. |
| _GE_ | Not used. |

## REMARKS:
1. E and G may not both be blank.
2. NU must be defined if either E or G is blank.
3. If only one E, G, or NU is blank, then it will be computed using the typical relationship.
