---
hide:
  - toc
---
Defines the properties of a PBEAM element.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| PBEAM | PID | MID | A | I1 | I2 | I12 | J | NSM |
| | C1 | C2 | D1 | D2 | E1 | E2 | F1 | F2 |  
| | K1 | K2 |    |   |   |   |   |   |  


## Fields
| Field      | Contents | Default Value |
| ---------- | -------- | ------------- |
| PID | Property identification number. (Integer > 0) | Required |
| MID | Material identification number. (Integer > 0) | Required |
| A | Area of the beam cross section. (Real > 0.0) | Required |
| I1 | Area moment of inertia for bending in plane 1 about the neutral axis. (Real > 0.0) | Required |
| I2 | Area moment of inertia for bending in plane 2 about the neutral axis. (Real > 0.0) | Required |
| I12 | Area product of inertia. Must be 0.0 or blank. | 0.0 |
| J | Torsional stiffness parameter. (Real) | Required |
| NSM | Nonstructural mass per unit length. (Real) | 0.0 |
| Ci, Di, Ei, Fi | The y and z locations (i = 1 corresponds to y and i = 2 corresponds to z) in element coordinates relative to the shear center (see the diagram following the remarks) for stress data recovery. (Real) | y = z = 0.0 |
| K1, K2 | Shear stiffness factor K in K*A*G for plane 1 and plane 2. See Remark 2. (Real) | 1.0, 1.0 |

## Remarks
1. The following figure describes the PBEAM element coordinate system.
![PBEAM element coordinate system.](https://raw.githubusercontent.com/vtpasquale/web_assets/assets/img/pbeam.svg)

where:
<p>
<img src="https://latex.codecogs.com/svg.latex?\Large&space; I1= I_{(zz)_{elem}}" />
</p><p>
<img src="https://latex.codecogs.com/svg.latex?\Large&space; I2= I_{(yy)_{elem}}" />
</p><p>
<img src="https://latex.codecogs.com/svg.latex?\Large&space; I12 = I_{(zy)_{elem}}" />
</p><p>
<img src="https://latex.codecogs.com/svg.latex?\Large&space; J = I_{(xx)_{elem}}" />
</p>

2. The orientation vector _v_ is defined by CBEAM entry fields X1, X2, and X3. 
3. The shear stiffness factors K1 and K2 adjust the effective transverse shear cross-section area according to the Timoshenko beam theory. The values of K1 and K2 can be set to 0.0 for Euler-Bernoulli beam theory.