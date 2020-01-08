%Hdf5NodalGrid_weight HDF5 data class for grid point weight data.

% <dataset name="GRID_WEIGHT">
% <field name="ID" type="integer"/>
% <field name="MO" type="double" size="36"/>
% <field name="S" type="double" size="9"/>
% <field name="MX" type="double"/>
% <field name="XX" type="double"/>
% <field name="YX" type="double"/>
% <field name="ZX" type="double"/>
% <field name="MY" type="double"/>
% <field name="XY" type="double"/>
% <field name="YY" type="double"/>
% <field name="ZY" type="double"/>
% <field name="MZ" type="double"/>
% <field name="XZ" type="double"/>
% <field name="YZ" type="double"/>
% <field name="ZZ" type="double"/>
% <field name="I" type="double" size="9"/>
% <field name="PIX" type="double"/>
% <field name="PIY" type="double"/>
% <field name="PIZ" type="double"/>
% <field name="Q" type="double" size="9"/>
% <field name="DOMAIN_ID" type="integer"/>
% </dataset>

% A. Ricciardi
% December 2019

classdef Hdf5NodalGrid_weight < Hdf5Nodal

    properties
        ID
        MO
        S
        MX
        XX
        YX
        ZX
        MY
        XY
        YY
        ZY
        MZ
        XZ
        YZ
        ZZ
        I
        PIX
        PIY
        PIZ
        Q
        DOMAIN_ID
    end
    properties (Constant = true)
        DATASET = 'GRID_WEIGHT'
    end
    methods
        function obj = Hdf5NodalGrid_weight(filename)
            if nargin < 1
            else
                obj = obj.import(filename);
            end
        end
    end
end

