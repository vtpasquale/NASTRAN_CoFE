classdef VtkScalar
    % class for vtk scalar data
    
    properties
        dataName % [char]
        data     % [n,1 double] vector data
    end
    
    methods
        function obj = VtkScalar(dataIn,dataNameIn)
            if size(dataIn,2)~=1; error('Scalar data dimension issue'); end
            obj.data = dataIn;
            obj.dataName = dataNameIn;
        end
        function print(obj,fid)
            % print to vtk file
            for i = 1:size(obj,1)
                fprintf(fid,'SCALARS %s float\n',obj(i).dataName);
                fprintf(fid,'LOOKUP_TABLE default\n');
                fprintf(fid,'%f\n',obj(i).data);
            end
        end
    end
end

