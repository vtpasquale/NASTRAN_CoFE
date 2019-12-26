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
        EID % [uint32] Element identification number 
        GRID % [integer] Number of active grids or corner grid ID
        SD % [double] Station distance divided by length
        BM1 % [double] Bending moment plane 1
        BM2 % [double] Bending moment plane 2
        TS1 % [double] Shear plane 1
        TS2 % [double] Shear plane 2
        AF % [double] Axial Force
        TTRQ % [double] Total Torque
        WTRQ % [double] Warping Torque
        DOMAIN_ID % [uint32] Domain identifier 
    end
    properties (Constant = true)
        DATASET = 'BEAM'; % Dataset name [char]
    end
    methods
        function obj = Hdf5ElementForceBeam(filename)
            if nargin < 1
            else
                obj = obj.import(filename);
            end
        end
    end   
end

