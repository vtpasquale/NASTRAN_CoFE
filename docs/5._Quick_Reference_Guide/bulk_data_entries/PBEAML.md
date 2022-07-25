---
hide:
  - toc
---
# PBEAML
Defines the properties of a CBEAM element by cross-sectional dimensions.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| PBEAML   | PID      | MID      | GROUP    | TYPE     |          |          |          |          |          | 
| DIM1     | DIM2     | etc.     | NSM      |          |          |          |          |          |          | 


## Fields
| Field      | Contents |
| ---------- | -------- |
| PID   | Property identification number. (Integer > 0)
| MID   | Material identification number. (Integer > 0)
| GROUP | Cross-section group. Must be `MSCBML0` or blank. (Character; Default = `MSCBML0`)
| TYPE  | Cross-section shape. See Remark 1. (Character: `ROD` or `BAR`)
| DIMi  | Cross-section dimensions. (Real > 0.0)
| NSM   | Nonstructural mass per unit length. (Real, Default = 0.0)

## Remarks
1. Cross-sections dimensions for TYPE=ROD

![ROD](https://raw.githubusercontent.com/vtpasquale/web_assets/assets/img/rod.svg)


2. Cross-sections dimensions for TYPE=BAR

![BAR](https://raw.githubusercontent.com/vtpasquale/web_assets/assets/img/bar.svg)
