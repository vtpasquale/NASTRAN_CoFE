%Hdf5NodalEigenvector HDF5 data class for GRID/SPOINT eigenvector data.

% <dataset name="EIGENVECTOR" version="1">
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

classdef Hdf5NodalEigenvector < Hdf5Nodal

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
        DATASET = 'EIGENVECTOR'
        SCHEMA_VERSION = uint32(1); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5NodalEigenvector(arg1,arg2)
            if nargin > 0
                if ischar(arg1)
                    obj = obj.importCompoundDatasetFromHdf5File(arg1);
                elseif isa(arg1,'NodeOutputData') 
                    obj = obj.constructFromNodeOutputData(arg1,arg2);
                    obj.version = obj.SCHEMA_VERSION;
                else
                    error('Constructor not implemented for this input type')
                end
            end
        end
    end
end

