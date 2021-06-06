%Hdf5ElementForceBeam HDF5 data class for CBEAM element force data.

% <dataset name="BEAM">
% <field name="EID" type="integer" description="Element identification number"/>
% <field name="FORCE" type="BEAM_FORCE" size="11" description="Element force structure for BEAM"/>
% <field name="DOMAIN_ID" type="integer" description="Domain identifier"/>
% </dataset>

% </typedef>
% <typedef name="BEAM_FORCE" description="Element force structure for BEAM">
% <field name="GRID" type="integer" description="Number of active grids or corner grid ID"/>
% <field name="SD" type="double" description="Station distance divided by length"/>
% <field name="BM1" type="double" description="Bending moment plane 1"/>
% <field name="BM2" type="double" description="Bending moment plane 2"/>
% <field name="TS1" type="double" description="Shear plane 1"/>
% <field name="TS2" type="double" description="Shear plane 2"/>
% <field name="AF" type="double" description="Axial Force"/>
% <field name="TTRQ" type="double" description="Total   Torque"/>
% <field name="WTRQ" type="double" description="Warping Torque"/>
% </typedef>

% A. Ricciardi
% December 2019

classdef Hdf5ElementForceBeam < Hdf5ElementForce
    
    properties
        EID % [n,1 uint32] Element identification number 
        GRID % [11,n integer] Number of active grids or corner grid ID
        SD % [11,n double] Station distance divided by length
        BM1 % [11,n double] Bending moment plane 1
        BM2 % [11,n double] Bending moment plane 2
        TS1 % [11,n double] Shear plane 1
        TS2 % [11,n double] Shear plane 2
        AF % [11,n double] Axial Force
        TTRQ % [11,n double] Total Torque
        WTRQ % [11,n double] Warping Torque
        DOMAIN_ID % [n,1 uint32] Domain identifier 
    end
    properties (Constant = true)
        DATASET = 'BEAM'; % Dataset name [char]
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementForceBeam(arg1,arg2)
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
        function obj1 = appendObj(obj1,obj2)
            % Appends the object data with data from another object
            % This is usually inherited from Hdf5CompoundDataset. This
            % element needs special treatment.
            obj2Struct = getStruct(obj2);
            enumerateFieldnames=fieldnames(obj2Struct)';
            for fn = enumerateFieldnames([1,11])
                obj1.(fn{1}) = [obj1.(fn{1});obj2Struct.(fn{1})]; % append object properties
            end
            for fn = enumerateFieldnames(2:10)
                obj1.(fn{1}) = [obj1.(fn{1}),obj2Struct.(fn{1})]; % append object properties
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
            obj = Hdf5ElementForceBeam();
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            
            nineZeros=[0.,0.,0.,0.,0.,0.,0.,0.,0.];
            blockZeros = repmat(nineZeros,[nVectors,1]);
            eid = [];
            grid0 = [];
            sd = zeros(nElements*nVectors,11); sd(:,11)=1.0;
            bm1 = [];
            bm2 = [];
            ts1 = [];
            ts2 = [];
            ttrq = [];
            af = [];
            domain_id = [];
            for i = 1:nElements
                
                eid = [eid;...
                       repmat(elementOutputData(i).elementID,[nVectors,1])];
                
                grid0 = [grid0;...
                    uint32(elementOutputData(i).values(13,:)).',...
                    blockZeros,...
                    uint32(elementOutputData(i).values(14,:)).'];
                
                bm1   = [bm1;...
                    elementOutputData(i).values(6,:).',...
                    blockZeros,...
                    elementOutputData(i).values(12,:).'];
                
                bm2   = [bm2;...
                    elementOutputData(i).values(5,:).',...
                    blockZeros,...
                    elementOutputData(i).values(11,:).'];
                
                ts2   = [ts2;...
                    elementOutputData(i).values(3,:).',...
                    blockZeros,...
                    elementOutputData(i).values(9,:).'];
                
                ts1   = [ts1;...
                    elementOutputData(i).values(2,:).',...
                    blockZeros,...
                    elementOutputData(i).values(8,:).'];
                
                ttrq = [ttrq;...
                    elementOutputData(i).values(4,:).',...
                    blockZeros,...
                    elementOutputData(i).values(10,:).'];
                
                af    = [af;...
                    elementOutputData(i).values(1,:).',...
                    blockZeros,...
                    elementOutputData(i).values(7,:).'];
                
                domain_id = [domain_id,domainIDs];
                
            end
            
            % Sort by domain id
            [~,index]=sort(domain_id);
            obj.EID  = eid(index);
            obj.GRID = grid0(index,:).';
            obj.SD   = sd.';
            obj.BM1  = bm1(index,:).'; 
            obj.BM2  = -1*bm2(index,:).'; % Nastran uses inconsistent sign convention
            obj.TS1  = ts1(index,:).';
            obj.TS2  = ts2(index,:).';
            obj.AF   = af(index,:).';
            obj.TTRQ = ttrq(index,:).';
            obj.WTRQ = zeros(size(sd)).';
            obj.DOMAIN_ID = domain_id(index).';
        end
    end
end

