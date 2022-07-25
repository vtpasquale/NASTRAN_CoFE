---
hide:
  - toc
---
# PARAM
Specifies values for parameters.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| PARAM    | N        | V1       | _V2_     |          |          |          |          |          |          |

## Fields
| Field      | Contents |
| ---------- | -------- |
| N | Parameter name. (Character) |
| V1 | Parameter value 1. (Real, Integer, or Character) |
| _V2_ | Not used. |

## Names and values

| Name       | V1 Type    | Default  | Description  |
| ---------- | ---------- | -------- | ------------ |
| COUPMASS   | Integer    | -1       | >0 requests the generation of coupled rather than lumped mass matrices. |
| K6ROT      | Real       | 100.0    | Used in the calculation of the stiffness for the out-of-plane rotational DOF for CQUAD4 and CTRIA3.  A value between 1.0 and 100.0 is recommended.|
| WTMASS     | Real       | 1.0      | Scale factor used to scale the mass matrix. It's useful to set WTMAS=0.00259 for inch models that input mass data in terms of pounds mass. |
| POST       | Integer    | 1        | <1 requests HDF5 output. The value for superelement 0 is applied to the entire model. |

## Remarks
1. PARAM entries with unrecognized parameter names are ignored.
