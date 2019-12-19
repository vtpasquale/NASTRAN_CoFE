%Hdf5Domains MSC Nastran format HDF5 domain output data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <dataset name="DOMAINS">
% <field name="ID" description="Domain identifier" type="integer"/>
% <field name="SUBCASE" description="Subcase number" type="integer"/>
% <field name="STEP" description="Step number" type="integer"/>
% <field name="ANALYSIS" description="Analysis type" type="integer"/>
% <field name="TIME_FREQ_EIGR" description="Time, frequency or real part of eigen value" type="double"/>
% <field name="EIGI" description="Imaginary part if eigen value (if applicable)" type="double"/>
% <field name="MODE" description="Mode number" type="integer"/>
% <field name="DESIGN_CYCLE" description="Design cycle" type="integer"/>
% <field name="RANDOM" description="Random code" type="integer"/>
% <field name="SE" description="Superelement number" type="integer"/>
% <field name="AFPM" description="afpm ????" type="integer"/>
% <field name="TRMC" description="trmc ????" type="integer"/>
% <field name="INSTANCE" description="Instance" type="integer"/>
% <field name="MODULE" description="Module" type="integer"/>
% </dataset>

% A. Ricciardi
% December 2019

classdef Hdf5Domains < Hdf5CompoundDataset
    
    properties
        ID             % Domain identifier [uint32]
        SUBCASE        % Subcase number [uint32]
        STEP           % Step number [uint32]
        ANALYSIS       % Analysis type [uint32]
        TIME_FREQ_EIGR % Time, frequency or real part of eigen value [double]
        EIGI           % Imaginary part if eigen value (if applicable) [double]
        MODE           % Mode number [uint32]
        DESIGN_CYCLE   % Design cycle [uint32]
        RANDOM         % Random code [uint32]
        SE             % Superelement number [uint32]
        AFPM           % afpm ???? [uint32]
        TRMC           % trmc ???? [uint32]
        INSTANCE       % Instance [uint32]
        MODULE         % Module [uint32]
    end
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/';
        DATASET = 'DOMAINS';
    end
    methods
        function obj = Hdf5Domains(arg1)
            if ischar(arg1)% arg1 = datasetString
                obj = obj.import(arg1);
            else
                error('Constructor not implemented for this type')
            end
        end
        function export(obj,file)
            % Exports the dataset to an HDF5 file.
            objStruct=getStruct(obj);
            struct2hdf52(file,obj.DATASET,objStruct,obj.version)
        end
    end
end
