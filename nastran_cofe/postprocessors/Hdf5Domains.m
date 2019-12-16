classdef Hdf5Domains
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID       % [n×1 int64]
        SUBCASE  % [n×1 int64]
        STEP     % [n×1 int64]
        ANALYSIS % [n×1 int64]
        TIME_FREQ_EIGR % [n×1 double]
        EIGI     % [n×1 double]
        MODE     % [n×1 int64]
        DESIGN_CYCLE % [n×1 int64]
        RANDOM   % [n×1 int64]
        SE       % [n×1 int64]
        AFPM     % [n×1 int64]
        TRMC     % [n×1 int64]
        INSTANCE % [n×1 int64]
        MODULE   % [n×1 int64]
    end
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/';
        DATASET = 'DOMAINS';
    end
    methods
        function objTable = getTable(obj)
            objStruct=getStruct(obj);
            objTable=struct2table(objStruct);
        end
        function writeToFile(obj,file)
            objStruct=getStruct(obj);
            struct2hdf52(file,obj.DATASET,objStruct)
        end
    end
    methods (Access = private)
        function objStruct = getStruct(obj)
            warning('off','MATLAB:structOnObject')
            objStruct=struct(obj);
            warning('on','MATLAB:structOnObject')
            objStruct=rmfield(objStruct,{'GROUP','DATASET'});
        end
    end
    methods (Static = true)
        function obj = constructFromFile(filename)
            obj = Hdf5Domains();  %create object
            fieldData = h5read(filename,[obj.GROUP,obj.DATASET]);
            for fn = fieldnames(fieldData)'    %enumerat fields
                obj.(fn{1}) = fieldData.(fn{1});   % copy to object properties
            end
        end
    end
    
end

