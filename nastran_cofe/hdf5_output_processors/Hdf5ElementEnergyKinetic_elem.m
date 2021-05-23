%Hdf5ElementEnergyKinetic_elem HDF5 data class for element Kinetic energy data.

% <dataset name="STRAIN_ELEM">
% <field name="ID" type="integer"/>
% <field name="ENERGY" type="double"/>
% <field name="PCT" type="double"/>
% <field name="DEN" type="double"/>
% <field name="IDENT" type="integer"/>
% <field name="DOMAIN_ID" type="integer"/>
% </dataset>

% A. Ricciardi
% May 2021

classdef Hdf5ElementEnergyKinetic_elem < Hdf5ElementEnergy
    
    properties
        ID  % [uint32] Element identification number
        ENERGY % [double] Kinetic energy
        PCT % [double] Kinetic energy percent of total
        DEN % [double]  Kinetic energy density
        IDENT % [double] ???
        DOMAIN_ID % [uint32] Domain identifier
    end
    properties (Constant = true)
        DATASET = 'KINETIC_ELEM'; % Dataset name [char]
        SCHEMA_VERSION = uint32(20190); % MSC dataset schema version used for CoFE development
    end
    methods
        function obj = Hdf5ElementEnergyKinetic_elem(arg1,arg2)
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
            % Function to convert element kinetic energy output data to HDF5
            %
            % INPUTS
            % elementOutputData [nElements,1 ElementOutputData] element kinetic energy output data
            % domainIDs [nVectors,1 unit32] HDF5 domain ID numbers
            %
            obj = Hdf5ElementEnergyKinetic_elem();
            
            nElements = size(elementOutputData,1);
            nVectors = size(elementOutputData(1).values,2);
            eid = [];
            energy = [];
            pct = [];
            den = [];
            domain_id = [];
                        
            for i = 1:nElements
                
                eid = [eid;repmat(elementOutputData(i).elementID,[nVectors,1])];
                energy    = [energy;elementOutputData(i).values(1,:).'];
                pct       = [pct;   elementOutputData(i).values(2,:).'];
                den       = [den;   elementOutputData(i).values(3,:).'];
                domain_id = [domain_id,domainIDs];
            end
            
            % Sort by domain id
            [~,index]=sort(domain_id);
            obj.ID =eid(index);
            obj.ENERGY=energy(index);
            obj.PCT=pct(index);
            obj.DEN=den(index);
            obj.IDENT=zeros(size(obj.ID)); % undocumented - fill with zeros
            obj.DOMAIN_ID = domain_id(index).';
        end
    end
end

