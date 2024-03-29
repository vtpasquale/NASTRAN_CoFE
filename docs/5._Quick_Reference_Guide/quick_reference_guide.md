# Quick Reference Guide
This _Quick Reference Guide_ documents CoFE input file entries. CoFE uses Nastran-format input data, so commercial preprocessing tools (e.g. Femap or PATRAN) can be used to create CoFE input files. Not all commercial-Nastran features are supported (e.g., shell offsets); limitations are documented in this guide.

CoFE ignores unrecognized executive control and case control entries. Unrecognized bulk data entries result in a fatal error at runtime.

## Executive Control Entries
* [SOL](executive_control_entries/SOL.md)

## Case Control Entries
**Abbreviated case control entries will be unrecognized and ignored.** For example, entering DISP rather than DISPLACEMENT, or SPCFORCE rather than SPCFORCES will result in the request being ignored.

* [ANALYSIS](case_control_entries/ANALYSIS.md)
* [DISPLACEMENT](case_control_entries/DISPLACEMENT.md)
* [EKE](case_control_entries/EKE.md)
* [ESE](case_control_entries/ESE.md)
* [FORCE](case_control_entries/FORCE-(Case-Control).md)
* [LABEL](case_control_entries/LABEL.md)
* [LOAD](case_control_entries/LOAD-(Case-Control).md)
* [METHOD](case_control_entries/METHOD.md)
* [SET](case_control_entries/SET.md)
* [SPC](case_control_entries/SPC-(Case-Control).md)
* [SPCFORCES](case_control_entries/SPCFORCES.md)
* [STRAIN](case_control_entries/STRAIN.md)
* [STRESS](case_control_entries/STRESS.md)
* [SUBCASE](case_control_entries/SUBCASE.md)
* [SUBTITLE](case_control_entries/SUBTITLE.md)
* [TITLE](case_control_entries/TITLE.md)

## Bulk Data Entries
* [CBAR](bulk_data_entries/CBAR.md)
* [CBEAM](bulk_data_entries/CBEAM.md)
* [CMASS1](bulk_data_entries/CMASS1.md)
* [CORD2C](bulk_data_entries/CORD2C.md)
* [CORD2R](bulk_data_entries/CORD2R.md)
* [CORD2S](bulk_data_entries/CORD2S.md)
* [CQUAD4](bulk_data_entries/CQUAD4.md)
* [CROD](bulk_data_entries/CROD.md)
* [CTRIA3](bulk_data_entries/CTRIA3.md)
* [EIGRL](bulk_data_entries/EIGRL.md)
* [FORCE](bulk_data_entries/FORCE-(Bulk-Data).md)
* [GRAV](bulk_data_entries/GRAV.md)
* [GRDSET](bulk_data_entries/GRDSET.md)
* [GRID](bulk_data_entries/GRID.md)
* [LOAD](bulk_data_entries/LOAD-(Bulk-Data).md)
* [MAT1](bulk_data_entries/MAT1.md)
* [MDLPRM](bulk_data_entries/MDLPRM.md)
* [MOMENT](bulk_data_entries/MOMENT.md)
* [PARAM](bulk_data_entries/PARAM.md)
* [PBAR](bulk_data_entries/PBAR.md)
* [PBEAM](bulk_data_entries/PBEAM.md)
* [PBEAML](bulk_data_entries/PBEAML.md)
* [PLOAD4](bulk_data_entries/PLOAD4.md)
* [PMASS](bulk_data_entries/PMASS.md)
* [PROD](bulk_data_entries/PROD.md)
* [PSHELL](bulk_data_entries/PSHELL.md)
* [RBE2](bulk_data_entries/RBE2.md)
* [RBE3](bulk_data_entries/RBE3.md)
* [SPC1](bulk_data_entries/SPC1.md)
* [SPC](bulk_data_entries/SPC.md)
* [SPCD](bulk_data_entries/SPCD.md)
* [SPOINT](bulk_data_entries/SPOINT.md)
