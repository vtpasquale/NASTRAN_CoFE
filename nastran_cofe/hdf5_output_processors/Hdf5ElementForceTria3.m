%Hdf5ElementForceTria3 HDF5 data class for TRIA3 force data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.html
% https://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <typedef name="QUAD4_FORCE">
% <field name="MX" type="double" description="Membrane force in x"/>
% <field name="MY" type="double" description="Membrane force in y"/>
% <field name="MXY" type="double" description="Membrane force in xy"/>
% <field name="BMX" type="double" description="Bending moment in x"/>
% <field name="BMY" type="double" description="Bending moment in y"/>
% <field name="BMXY" type="double" description="Bending moment in xy"/>
% <field name="TX" type="double" description="Shear force in x"/>
% <field name="TY" type="double" description="Shear force in y"/>
% </typedef>

% A. Ricciardi
% June 2021

classdef Hdf5ElementForceTria3 < Hdf5ElementForce
    
    properties
        EID % [uint32] Element identification number
        MX % [double] Membrane force in x
        MY % [double] Membrane force in y
        MXY % [double] Membrane force in xy
        BMX % [double] Bending moment in x
        BMY % [double] Bending moment in y
        BMXY % [double] Bending moment in xy
        TX % [double] Shear force in x
        TY % [double] Shear force in y
        DOMAIN_ID % [uint32] Domain identifier
    end
    properties (Constant = true)
        DATASET = 'TRIA3'; % Dataset name [char]
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementForceTria3(arg1,arg2)
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
            % Function to convert element force output data to HDF5
            %
            % INPUTS
            % elementOutputData [nElements,1 ElementOutputData] element force output data
            % domainIDs [nVectors,1 unit32] HDF5 domain ID numbers
            %
            obj = Hdf5ElementForceTria3();
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            eid = [];
            mx = [];
            my = [];
            mxy = [];
            bmx = [];
            bmy = [];
            bmxy = [];
            tx = [];
            ty = [];
            domain_id = [];
            for i = 1:nElements
                eid = [eid,repmat(elementOutputData(i).elementID,[1,nVectors])];
                
                mx = [mx,elementOutputData(i).values(1,:)];
                my = [my,elementOutputData(i).values(2,:)];
                mxy = [mxy,elementOutputData(i).values(3,:)];
                
                bmx = [bmx,elementOutputData(i).values(4,:)];
                bmy = [bmy,elementOutputData(i).values(5,:)];
                bmxy = [bmxy,elementOutputData(i).values(6,:)];
                tx = [tx,elementOutputData(i).values(7,:)];
                ty = [ty,elementOutputData(i).values(8,:)];
                
                domain_id = [domain_id,domainIDs];
            end
            % sort by domain id
            [~,index]=sort(domain_id);
            obj.EID = eid(index).';
            
            obj.MX = mx(index).';
            obj.MY = my(index).';
            obj.MXY = mxy(index).';
            
            obj.BMX = bmx(index).';
            obj.BMY = bmy(index).';
            obj.BMXY = bmxy(index).';
            
            obj.TX = tx(index).';
            obj.TY = ty(index).';
            
            obj.DOMAIN_ID = domain_id(index).';
        end
    end
end

