%Hdf5NodalSpc_force HDF5 data class for GRID/SPOINT SPC force data.

% <dataset name="SPC_FORCE" version="1">
% <field name="ID" type="integer" description="Grid identifier"/>
% <field name="X"  type="double" description="X component"/>
% <field name="Y"  type="double" description="Y component"/>
% <field name="Z"  type="double" description="Z component"/>
% <field name="RX" type="double" description="RX component"/>
% <field name="RY" type="double" description="RY component"/>
% <field name="RZ" type="double" description="RZ component"/>
% <field name="DOMAIN_ID" type="integer" description="Domain identifier"/>
% </dataset>

% A. Ricciardi
% December 2019

classdef Hdf5NodalSpc_force < Hdf5Nodal

    properties
        ID % [integer] Grid identifier
        X % [double] X component
        Y % [double] Y component
        Z % [double] Z component
        RX % [double] RX component
        RY % [double] RY component
        RZ % [double] RZ component
        DOMAIN_ID % [integer] Domain identifier
    end
    properties (Constant = true)
        DATASET = 'SPC_FORCE'
        SCHEMA_VERSION = uint32(1); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5NodalSpc_force(filename)
            if nargin < 1
            else
                obj = obj.importCompoundDatasetFromHdf5File(filename);
            end
        end
    end
end

