%Hdf5ElementForceRod HDF5 data class for CROD element force data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.html
% https://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <dataset name="ROD">
% <field name="EID" description="Element identification number" type="integer"/>
% <field name="AF" description="Axial Force" type="double"/>
% <field name="TRQ" description="Torque" type="double"/>
% <field name="DOMAIN_ID" description="Domain identifier" type="integer"/>
% </dataset>

% A. Ricciardi
% December 2019

classdef Hdf5ElementForceRod < Hdf5ElementForce
    
    properties
        EID       % Element identification number [uint32]
        AF        % Axial Force [double]
        TRQ       % Torque [double]
        DOMAIN_ID % Domain identifier [uint32]
    end
    properties (Constant = true)
        DATASET = 'ROD'; % Dataset name [char]
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementForceRod(arg1,arg2)
            if nargin > 0
                if ischar(arg1)
                    obj = obj.import(arg1);
                elseif isa(arg1,'ElementOutputData') 
                    obj = obj.constructFromElementOutputData(arg1,arg2);
                    obj.version = obj.SCHEMA_VERSION;
                else
                    error('Constructor not implemented for this input type')
                end
            end
        end
    end
    methods (Static=true)
        function obj = constructFromElementOutputData(elementOutputData,domainIDs)
            % Function to convert element force output data to HDF5
            %
            % INPUTS
            % elementOutputData [nElements,1 ElementOutputData] element force output data
            % domainIDs [nVectors,1 unit32] HDF5 domain ID numbers
            %
            obj = Hdf5ElementForceRod();
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            eid = [];
            af = [];
            trq = [];
            domain_id = [];
            for i = 1:nElements
                eid = [eid,repmat(elementOutputData(i).elementID,[1,nVectors])];
                af = [af,elementOutputData(i).values(1,:)];
                trq = [trq,elementOutputData(i).values(2,:)];
                domain_id = [domain_id,domainIDs];
            end
            % sort by domain id
            [~,index]=sort(domain_id);
            obj.EID = eid(index).';
            obj.AF = af(index).';
            obj.TRQ = trq(index).';
            obj.DOMAIN_ID = domain_id(index).';
        end
    end
    
    
end

