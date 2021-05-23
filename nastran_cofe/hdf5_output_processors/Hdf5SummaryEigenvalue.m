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
        function obj = Hdf5SummaryEigenvalue(arg1)
            if nargin > 0
                if ischar(arg1)
                    obj = obj.importCompoundDatasetFromHdf5File(arg1);
                elseif isa(arg1,'ModesSolution') 
                    obj = obj.constructFromModesSolution(arg1);
                    obj.version = obj.SCHEMA_VERSION;
                else
                    error('Constructor not implemented for this input type')
                end
            end
        end
    end
    methods (Static = true)
        function obj = constructFromModesSolution(modesSolution)
            % Function to construct HDF5 summary from modes solution
            %
            % INPUTS
            % modesSolution [1,1 ModesSolution] Modes Solution
            if length(modesSolution)~=1; error('Input should be a single modes solution'); end
            obj=Hdf5SummaryEigenvalue();
            et = modesSolution.eigenvalueTable;
            n = size(et.eigenvalue,1);
            obj.MODE  = int32(1:n).';
            obj.ORDER = obj.MODE ;
            obj.EIGEN = et.eigenvalue;
            obj.OMEGA = et.angularFrequency;
            obj.FREQ  = et.frequency;
            obj.MASS  = et.generalizedMass;
            obj.STIFF = et.generalizedStiffness;
            obj.RESFLG = zeros(n,1,'int32');
            obj.FLDFLG = zeros(n,1,'int32');
            obj.DOMAIN_ID = modesSolution.vectorHdf5DomainID;
        end
    end
end

