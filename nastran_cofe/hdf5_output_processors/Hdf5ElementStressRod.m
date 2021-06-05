%Hdf5ElementStressRod HDF5 data class for CROD stress data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.html
% https://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <dataset name="ROD">
% <field name="EID" type="integer" description="Element identification number"/>
% <field name="A" type="double" description="Axial stress"/>
% <field name="MSA" type="double" description="Axial Safety Margin*"/>
% <field name="T" type="double" description="Total stress"/>
% <field name="MST" type="double" description="Margin of Safety in Tension"/>
% <field name="DOMAIN_ID" type="integer" description="Domain identifier"/>
% </dataset>

% A. Ricciardi
% June 2021

classdef Hdf5ElementStressRod < Hdf5ElementStress
    
    properties
        EID % [uint32] Element identification number
        A % [double] Axial stress
        MSA % [double] Axial Safety Margin
        T % [double] Torsion? stress
        MST % [double] Margin of Safety in Torsion?
        DOMAIN_ID % [uint32] Domain identifier
    end
    properties (Constant = true)
        DATASET = 'ROD'; % Dataset name [char]
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementStressRod(arg1,arg2)
            if nargin > 0
                if ischar(arg1)
                    obj = obj.importCompoundDatasetFromHdf5File(arg1);
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
            % Function to convert element stress output data to HDF5
            %
            % INPUTS
            % elementOutputData [nElements,1 ElementOutputData] element stress output data
            % domainIDs [nVectors,1 unit32] HDF5 domain ID numbers
            %
            obj = Hdf5ElementStressRod();
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            eid = [];
            a = [];
            t = [];
            domain_id = [];
            for i = 1:nElements
                eid = [eid,repmat(elementOutputData(i).elementID,[1,nVectors])];
                a = [a,elementOutputData(i).values(1,:)];
                t = [t,elementOutputData(i).values(2,:)];
                domain_id = [domain_id,domainIDs];
            end
            % sort by domain id
            [~,index]=sort(domain_id);
            obj.EID = eid(index).';
            obj.A = a(index).';
            obj.T = t(index).';
            obj.DOMAIN_ID = domain_id(index).';
            
            % CoFE does not support margins - set to zero
            n = size(obj.DOMAIN_ID,1);
            obj.MSA =zeros(n,1);
            obj.MST =zeros(n,1);
        end
    end
    
    
end

