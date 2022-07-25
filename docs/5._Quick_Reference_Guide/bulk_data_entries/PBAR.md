---
hide:
  - toc
---
# PBAR
Defines the properties of a CBAR element.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| PBAR | PID | MID | A | I1 | I2 | J | NSM |   |  
| | C1 | C2 | D1 | D2 | E1 | E2 | F1 | F2 |  
| | K1 | K2 | I12 |   |   |   |   |   |  


## Fields
| Field      | Contents | Default Value |
| ---------- | -------- | ------------- |
| PID | Property identification number. (Integer > 0) | Required |
| MID | Material identification number. (Integer > 0) | Required |
| A | Area of the beam cross section. (Real > 0.0) | Required |
| I1 | Area moment of inertia for bending in plane 1 about the neutral axis. (Real > 0.0) | Required |
| I2 | Area moment of inertia for bending in plane 2 about the neutral axis. (Real > 0.0) | Required |
| J | Torsional stiffness parameter. (Real) | Required |
| NSM | Nonstructural mass per unit length. (Real) | 0.0 |
| Ci, Di, Ei, Fi | The y and z locations (i = 1 corresponds to y and i = 2 corresponds to z) in element coordinates relative to the shear center (see the diagram following the remarks) for stress data recovery. (Real) | y = z = 0.0 |
| K1, K2 | Shear stiffness factor K in K*A*G for plane 1 and plane 2. See Remark 2. (Real) | 0.0, 0.0 |
| I12 | Area product of inertia. Must be 0.0 or blank. | 0.0 |
