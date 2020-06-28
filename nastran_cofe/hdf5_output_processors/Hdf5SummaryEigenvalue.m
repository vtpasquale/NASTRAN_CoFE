%Hdf5SummaryEigenvalue HDF5 data class for eigenvalue data.

% <dataset name="EIGENVALUE">
% <field name="MODE" type="integer"/>
% <field name="ORDER" type="integer"/>
% <field name="EIGEN" type="double"/>
% <field name="OMEGA" type="double"/>
% <field name="FREQ" type="double"/>
% <field name="MASS" type="double"/>
% <field name="STIFF" type="double"/>
% <field name="RESFLG" type="integer"/>
% <field name="FLDFLG" type="integer"/>
% <field name="DOMAIN_ID" type="integer" description="Domain identifier"/>
% </dataset>

% A. Ricciardi
% Jan 2020

classdef Hdf5SummaryEigenvalue < Hdf5Summary

    properties
        MODE
        ORDER
        EIGEN
        OMEGA
        FREQ
        MASS
        STIFF
        RESFLG
        FLDFLG
        DOMAIN_ID 
    end
    properties (Constant = true)
        DATASET = 'EIGENVALUE'
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5SummaryEigenvalue(filename)
            if nargin < 1
            else
                obj = obj.importCompoundDatasetFromHdf5File(filename);
            end
        end
    end
end

