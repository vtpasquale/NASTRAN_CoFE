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
        function obj = Hdf5ElementForceRod(filename)
            if nargin < 1
            else
                obj = obj.import(filename);
            end
        end
    end   
end

