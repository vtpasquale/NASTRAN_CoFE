%Hdf5ElementForceBar HDF5 data class for BAR element force data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <dataset name="BAR">
% <field name="EID" type="integer" description="Element identification number"/>
% <field name="BM1A" type="double" description="Bending moment end A plane 1"/>
% <field name="BM2A" type="double" description="Bending moment end A plane 2"/>
% <field name="BM1B" type="double" description="Bending moment end B plane 1"/>
% <field name="BM2B" type="double" description="Bending moment end B plane 2"/>
% <field name="TS1" type="double" description="Shear plane 1"/>
% <field name="TS2" type="double" description="Shear plane 2"/>
% <field name="AF" type="double" description="Axial Force"/>
% <field name="TRQ" type="double" description="Torque"/>
% <field name="DOMAIN_ID" type="integer" description="Domain identifier"/>
% </dataset>

% A. Ricciardi
% June 2020

classdef Hdf5ElementForceBar < Hdf5ElementForce
    
    properties
        EID  % [uint32] Element identification number
        BM1A % [double] Bending moment end A plane 1
        BM2A % [double] Bending moment end A plane 2
        BM1B % [double] Bending moment end B plane 1
        BM2B % [double] Bending moment end B plane 2
        TS1  % [double] Shear plane 1
        TS2  % [double] Shear plane 2
        AF   % [double] Axial Force
        TRQ  % [double] Torque
        DOMAIN_ID % [uint32] Domain identifier
    end
    properties (Constant = true)
        DATASET = 'BAR'; % Dataset name [char]
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementForceBar(arg1,arg2)
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
    methods (Static = true)
        function obj = constructFromElementOutputData(elementOutputData,domainIDs)
            % Function to convert element force output data to HDF5
            %
            % INPUTS
            % elementOutputData [nElements,1 ElementOutputData] element force output data
            % domainIDs [nVectors,1 unit32] HDF5 domain ID numbers
            %
            obj = Hdf5ElementForceBar();
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            eid = [];
            bm1a = [];
            bm2a = [];
            bm1b = [];
            bm2b = [];
            ts1 = [];
            ts2 = [];
            trq = [];
            af = [];
            domain_id = [];
            for i = 1:nElements
                
                eid = [eid;repmat(elementOutputData(i).elementID,[nVectors,1])];
                
                bm1a   = [bm1a;elementOutputData(i).values(6,:).'];
                bm1b   = [bm1b;elementOutputData(i).values(12,:).'];
                
                bm2a   = [bm2a;elementOutputData(i).values(5,:).'];
                bm2b   = [bm2b;elementOutputData(i).values(11,:).'];
                
                ts2   = [ts2;elementOutputData(i).values(3,:).'];
                ts1   = [ts1;elementOutputData(i).values(2,:).'];
                
                trq = [trq;elementOutputData(i).values(4,:).'];
                
                af    = [af;elementOutputData(i).values(1,:).'];
                
                domain_id = [domain_id,domainIDs];
                
            end
            
            % Sort by domain id
            [~,index]=sort(domain_id);
            obj.EID =eid(index);
            obj.BM1A=bm1a(index);
            obj.BM2A=bm2a(index);
            obj.BM1B=bm1b(index);
            obj.BM2B=bm2b(index);
            obj.TS1 =ts1(index);
            obj.TS2 =ts2(index);
            obj.AF  =af(index);
            obj.TRQ =trq(index);
            obj.DOMAIN_ID = domain_id(index).';
        end
    end
end

