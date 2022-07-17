Defines the membrane, bending, and transverse shear properties for CTRIA3 and CQUAD4 elements.

## Format

| 1      | 2   | 3    | 4    | 5    | 6          | 7    | 8    | 9   |
| ------ | --- | ---- | ---- | ---- | ---------- | ---- | ---- | --- |
| PSHELL | PID | MID1 | T    | MID2 | 12I/T\*\*3 | MID3 | TS/T | NSM |
|        | Z1  | Z2   | MID4 |      |            |      |      |     |

## Example
`PSHELL,105,501,0.0833,501,,501,,4.0`

## Fields

| Field        | Contents                                                                                                                                                                                                                                                |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PID          | Property identification number. (Integer \> 0)                                                                                                                                                                                                          |
| MID1         | Material identification number for the membrane. (Integer \> 0 or blank)                                                                                                                                                                                |
| T            | Default membrane thickness for Ti on the connection entry. If T is blank then the thickness must be specified for Ti on the CQUAD4. (Real or blank) Thickness scale factor if TFLAG = 1 ($T\_i=T\_i \* T$)                                              |
| MID2         | Material identification number for bending. (Integer ≥ -1 or blank)                                                                                                                                                                                     |
| 12I/T\*\*3   | Bending moment of inertia ratio, $12I/T^3$. Ratio of the actual bending moment inertia of the shell, $I$, to the bending moment of inertia of a homogeneous shell, $T^3/12$. The default value is for a homogeneous shell. (Real \> 0.0; Default = 1.0) |
| MID3         | Material identification number for transverse shear. (Integer \> 0 or blank)                                                                                                                                                                            |
| TS/T         | Transverse shear thickness ratio $T\_s/T$. Ratio of the shear thickness, $T\_s$, to the membrane thickness of the shell, $T$. The default value is for a homogeneous shell. (Real \> 0.0; Default = .833333)                                            |
| NSM          | Nonstructural mass per unit area. (Real)                                                                                                                                                                                                                |
| Z1, Z2, MID4 | Not used.                                                                                                                                                                                                                                               |

## Remarks:
1.  The continuation is optional.
2.  Mindlin-Reissner theory of plates (first-order shear plate theory)
    will be used if MID2 ≥ 1. Kirchhoff or classical plate theory (no
    shear flexibility) is not supported.
3.  The results of leaving an MID field blank (or MID2 = -1) are:
  - MID1 - No membrane stiffness
  - MID2 - No bending or transverse shear stiffness
  - MID3 - MID2 used to define transverse shear material properties