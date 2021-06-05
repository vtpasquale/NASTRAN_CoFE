%Hdf5ElementStrainBeam HDF5 data class for CBEAM strain data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.html
% https://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <typedef name="BEAM_SS" description="Strain and stress structure for BEAM">
% <field name="GRID" type="integer" description="External Grid Point ID"/>
% <field name="SD" type="double" description="Station distance divided by length"/>
% <field name="XC" type="double" description="Longitudonal Stress or Strain at Point C"/>
% <field name="XD" type="double" description="Longitudonal Stress or Strain at Point D"/>
% <field name="XE" type="double" description="Longitudonal Stress or Strain at Point E"/>
% <field name="XF" type="double" description="Longitudonal Stress or Strain at Point F"/>
% <field name="MAX" type="double" description="Maximal Stress or Strain"/>
% <field name="MIN" type="double" description="Minimal Stress or Strain"/>
% <field name="MST" type="double" description="Margin of Safety in Tension"/>
% <field name="MSC" type="double" description="Margin of Safety in Compression"/>
% </typedef>

% A. Ricciardi
% June 2021

classdef Hdf5ElementStrainBeam < Hdf5ElementStrain
    
    properties
        EID % [n,1 uint32] Element identification number 
        GRID % [11,n uint32] External Grid Point ID
        SD % [11,n double] Station distance divided by length
        XC % [11,n double] Longitudonal Stress or Strain at Point C
        XD % [11,n double] Longitudonal Stress or Strain at Point D
        XE % [11,n double] Longitudonal Stress or Strain at Point E
        XF % [11,n double] Longitudonal Stress or Strain at Point F
        MAX % [11,n double] Maximal Stress or Strain
        MIN % [11,n double] Minimal Stress or Strain
        MST % [11,n double] Margin of Safety in Tension
        MSC % [11,n double] Margin of Safety in Compression
        DOMAIN_ID % [n,1 uint32] Domain identifier 
    end
    properties (Constant = true)
        DATASET = 'BEAM'; % Dataset name [char]
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementStrainBeam(arg1,arg2)
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
            obj = Hdf5ElementStrainBeam();
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            
            nineZeros=[0.,0.,0.,0.,0.,0.,0.,0.,0.];
            blockZeros = repmat(nineZeros,[nVectors,1]);
            eid = [];
            grid0 = [];
            sd = zeros(nElements*nVectors,11); sd(:,11)=1.0;
            xc = [];
            xd = [];
            xe = [];
            xf = [];
            myMin = [];
            myMax = [];
            domain_id = [];
            for i = 1:nElements
                
                eid = [eid;...
                       repmat(elementOutputData(i).elementID,[nVectors,1])];
                
                grid0 = [grid0;...
                    uint32(elementOutputData(i).values(9,:)).',...
                    blockZeros,...
                    uint32(elementOutputData(i).values(10,:)).'];
                
                xc   = [xc;...
                    elementOutputData(i).values(1,:).',...
                    blockZeros,...
                    elementOutputData(i).values(5,:).'];
                
                xd   = [xd;...
                    elementOutputData(i).values(2,:).',...
                    blockZeros,...
                    elementOutputData(i).values(6,:).'];
                
                xf   = [xf;...
                    elementOutputData(i).values(4,:).',...
                    blockZeros,...
                    elementOutputData(i).values(8,:).'];
                
                xe   = [xe;...
                    elementOutputData(i).values(3,:).',...
                    blockZeros,...
                    elementOutputData(i).values(7,:).'];
                
                myMin   = [myMin;...
                    min(elementOutputData(i).values(1:4,:) ).',...
                    blockZeros,...
                    min(elementOutputData(i).values(5:8,:) ).'];
                
                myMax   = [myMax;...
                    max(elementOutputData(i).values(1:4,:) ).',...
                    blockZeros,...
                    max(elementOutputData(i).values(5:8,:) ).'];
                
                domain_id = [domain_id,domainIDs];
                
            end
            
            % Sort by domain id
            [~,index]=sort(domain_id);
            obj.EID  = eid(index);
            obj.GRID = grid0(index,:).';
            obj.SD   = sd.';
            obj.XC  = xc(index,:).'; 
            obj.XD  = xd(index,:).'; 
            obj.XE  = xe(index,:).';
            obj.XF  = xf(index,:).';
            obj.MIN  = myMin(index,:).';
            obj.MAX = myMax(index,:).';
            obj.MST = zeros(size(sd)).';
            obj.MSC = zeros(size(sd)).';
            obj.DOMAIN_ID = domain_id(index).';
        end
    end
    
    
end

