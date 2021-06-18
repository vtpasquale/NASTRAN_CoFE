%Hdf5ElementStrainBeam HDF5 data class for QUAD strain data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.html
% https://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <dataset name="QUAD4">
% <field name="EID" type="integer" description="Element identification number"/>
% <field name="FD1" type="double" description="Z1 = Fiber distance"/>
% <field name="X1" type="double" description="Normal in X at Z1"/>
% <field name="Y1" type="double" description="Normal in Y at Z1"/>
% <field name="XY1" type="double" description="Shear in XY at Z1"/>
% <field name="FD2" type="double" description="Z2 = Fiber distance"/>
% <field name="X2" type="double" description="Normal in X at Z2"/>
% <field name="Y2" type="double" description="Normal in Y at Z2"/>
% <field name="XY2" type="double" description="Shear in XY at Z2"/>
% <field name="DOMAIN_ID" type="integer" description="Domain identifier"/>
% </dataset>

% A. Ricciardi
% June 2021

classdef Hdf5ElementStrainQuad4 < Hdf5ElementStrain
    
    properties
        EID % [uint32] Element identification number
        FD1 % [double] Z1 = Fiber distance
        X1 % [double] Normal in X at Z1
        Y1 % [double] Normal in Y at Z1
        TXY1 % [double] Shear in XY at Z1
        FD2 % [double] Z2 = Fiber distance
        X2 % [double] Normal in X at Z2
        Y2 % [double] Normal in Y at Z2
        TXY2 % [double] Shear in XY at Z2
        DOMAIN_ID % [uint32] Domain identifier
    end
    properties (Constant = true)
        DATASET = 'QUAD'; % Dataset name [char]
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementStrainQuad4(arg1,arg2)
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
            % Function to convert element strain output data to HDF5
            %
            % INPUTS
            % elementOutputData [nElements,1 ElementOutputData] element strain output data
            % domainIDs [nVectors,1 unit32] HDF5 domain ID numbers
            %
            obj = Hdf5ElementStrainQuad4();
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            eid = [];
            fd1 = [];
            x1 = [];
            y1 = [];
            txy1 = [];
            fd2 = [];
            x2 = [];
            y2 = [];
            txy2 = [];
            domain_id = [];
            for i = 1:nElements
                eid = [eid,repmat(elementOutputData(i).elementID,[1,nVectors])];
                
                fd1 = [fd1,elementOutputData(i).values(1,:)];
                x1 = [x1,elementOutputData(i).values(2,:)];
                y1 = [y1,elementOutputData(i).values(3,:)];
                txy1 = [txy1,elementOutputData(i).values(4,:)];
                
                fd2 = [fd2,elementOutputData(i).values(9,:)];
                x2 = [x2,elementOutputData(i).values(10,:)];
                y2 = [y2,elementOutputData(i).values(11,:)];
                txy2 = [txy2,elementOutputData(i).values(12,:)];
                
                domain_id = [domain_id,domainIDs];
            end
            % sort by domain id
            [~,index]=sort(domain_id);
            obj.EID = eid(index).';
            
            obj.FD1 = fd1(index).';
            obj.X1 = x1(index).';
            obj.Y1 = y1(index).';
            obj.TXY1 = txy1(index).';
            
            obj.FD2 = fd2(index).';
            obj.X2 = x2(index).';
            obj.Y2 = y2(index).';
            obj.TXY2 = txy2(index).';
            
            obj.DOMAIN_ID = domain_id(index).';
        end
    end
    
    
end

