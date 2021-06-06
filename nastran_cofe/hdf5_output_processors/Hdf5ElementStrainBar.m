%Hdf5ElementStrainBar HDF5 data class for BAR element strain data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <dataset name="BAR">
% <field name="EID" type="integer" description="Element identification number"/>
% <field name="X1A" type="double" description="SA1"/>
% <field name="X2A" type="double" description="SA2"/>
% <field name="X3A" type="double" description="SA3"/>
% <field name="X4A" type="double" description="SA4"/>
% <field name="AX" type="double" description="Axial"/>
% <field name="MAXA" type="double" description="SA maximum"/>
% <field name="MINA" type="double" description="SA minimum"/>
% <field name="MST" type="double" description="Margin of Safety in Tension"/>
% <field name="X1B" type="double" description="SB1"/>
% <field name="X2B" type="double" description="SB2"/>
% <field name="X3B" type="double" description="SB3"/>
% <field name="X4B" type="double" description="SB4"/>
% <field name="MAXB" type="double" description="SB maximum"/>
% <field name="MINB" type="double" description="SB minimum"/>
% <field name="MSC" type="double" description="Margin of Safety in Compression"/>
% <field name="DOMAIN_ID" type="integer" description="Domain identifier"/>
% </dataset>

% A. Ricciardi
% June 2020

classdef Hdf5ElementStrainBar < Hdf5ElementStrain
    
    properties
        EID % [uint32] Element identification number
        X1A % [double] SA1
        X2A % [double] SA2
        X3A % [double] SA3
        X4A % [double] SA4
        AX % [double] Axial
        MAXA % [double] SA maximum
        MINA % [double] SA minimum
        MST % [double] Margin of Safety in Tension
        X1B % [double] SB1
        X2B % [double] SB2
        X3B % [double] SB3
        X4B % [double] SB4
        MAXB % [double] SB maximum
        MINB % [double] SB minimum
        MSC % [double] Margin of Safety in Compression
        DOMAIN_ID % [uint32] Domain identifier
    end
    properties (Constant = true)
        DATASET = 'BAR'; % Dataset name [char]
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementStrainBar(arg1,arg2)
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
    methods (Static = true)
        function obj = constructFromElementOutputData(elementOutputData,domainIDs)
            % Function to convert element strain output data to HDF5
            %
            % INPUTS
            % elementOutputData [nElements,1 ElementOutputData] element strain output data
            % domainIDs [nVectors,1 unit32] HDF5 domain ID numbers
            %
            obj = Hdf5ElementStrainBar();
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            eid = [];
            
            x1a = [];
            x2a = [];
            x3a = [];
            x4a = [];
            ax = [];
            mina = [];
            maxa = [];
            
            x1b = [];
            x2b = [];
            x3b = [];
            x4b = [];
            minb = [];
            maxb = [];
            
            domain_id = [];
            for i = 1:nElements
                
                eid = [eid;repmat(elementOutputData(i).elementID,[nVectors,1])];
                
                x1a   = [x1a;elementOutputData(i).values(1,:).'];
                x2a   = [x2a;elementOutputData(i).values(2,:).'];
                x3a   = [x3a;elementOutputData(i).values(3,:).'];
                x4a   = [x4a;elementOutputData(i).values(4,:).'];
                ax   = [ax;mean(elementOutputData(i).values(1:4,:)).'];
                maxa   = [maxa;max(elementOutputData(i).values(1:4,:)).'];
                mina   = [mina;min(elementOutputData(i).values(1:4,:)).'];
                
                x1b   = [x1b;elementOutputData(i).values(5,:).'];
                x2b   = [x2b;elementOutputData(i).values(6,:).'];
                x3b   = [x3b;elementOutputData(i).values(7,:).'];
                x4b   = [x4b;elementOutputData(i).values(8,:).'];
                maxb   = [maxb;max(elementOutputData(i).values(5:8,:)).'];
                minb   = [minb;min(elementOutputData(i).values(5:8,:)).'];
                
                domain_id = [domain_id,domainIDs];
            end
            
            % Sort by domain id
            [~,index]=sort(domain_id);
            obj.EID =eid(index);
            obj.AX=ax(index);
            
            obj.X1A=x1a(index) - obj.AX; % seperate bending and axis stress before saving
            obj.X2A=x2a(index) - obj.AX;
            obj.X3A=x3a(index) - obj.AX;
            obj.X4A=x4a(index) - obj.AX;
            
            obj.MAXA =maxa(index);
            obj.MINA =mina(index);
            
            obj.X1B=x1b(index) - obj.AX;
            obj.X2B=x2b(index) - obj.AX;
            obj.X3B=x3b(index) - obj.AX;
            obj.X4B=x4b(index) - obj.AX;
            obj.MAXB =maxb(index);
            obj.MINB =minb(index);
            
            % Margins unsupported. Set to zero.
            obj.MST = zeros(size(obj.EID));
            obj.MSC = obj.MST;

            obj.DOMAIN_ID = domain_id(index).';
        end
    end
end

