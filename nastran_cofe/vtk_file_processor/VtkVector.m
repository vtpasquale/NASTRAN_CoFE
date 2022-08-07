classdef VtkVector
    % class for vtk vector data
    
    properties
        dataName % [char]
        data     % [n,3 double] vector data
    end
    
    methods
        function obj = VtkVector(dataIn,dataNameIn)
            if nargin > 0
                obj.data = dataIn;
                obj.dataName = dataNameIn;
            end
        end
        function print(obj,fid)
            % print to vtk file
            for i = 1:size(obj,1)
                fprintf(fid,'VECTORS %s float\n',obj(i).dataName);
                fprintf(fid,'%f %f %f\n',obj(i).data.');
            end
        end
    end
    methods (Static=true)
        function vtkVector = fromSolution(solution,vtkPointIDs)
            % Creates vtk point vector output data from Solution object
            nSubCases = size(solution,1);
            vtkVector = VtkVector();
            index = 0;
            for i = 1:nSubCases
                subcasePrefix = sprintf('Sc%d_',i);
                if ~isempty(solution(i,1).displacement)
                    vtkVectorNext = VtkVector.fromPointOutputData(solution(i,1).displacement,vtkPointIDs,subcasePrefix);
                    addIndex = size(vtkVectorNext,1);
                    vtkVector(index+1:index+addIndex,:) = vtkVectorNext;
                    index = index + addIndex;
                end
                if ~isempty(solution(i,1).spcforces)
                    vtkVectorNext = VtkVector.fromPointOutputData(solution(i,1).spcforces,vtkPointIDs,subcasePrefix);
                    addIndex = size(vtkVectorNext,1);
                    vtkVector(index+1:index+addIndex,:) = vtkVectorNext;
                    index = index + addIndex;
                end
            end
        end
        function vtkVector = fromPointOutputData(pointOutputData,vtkPointIDs,subcasePrefix)
            switch pointOutputData.responseType  % [uint8] CoFE code specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
                case 1
                    tType='translation';
                    rType='rotation';
                case 4
                    tType='spc-force';
                    rType='spc-moment';
                otherwise
                    error('Response type not supported')
            end
            [nNodes,nVectors] = size(pointOutputData.T1);
            nVtkNodes = size(vtkPointIDs,1);
            if nNodes > nVtkNodes; error('There are more results nodes than VTK nodes'); end
            preallocate = zeros(nVtkNodes,3);
            recoveredFlag = ismember(vtkPointIDs,pointOutputData.ID);
            
            vtkVector = VtkVector();
            index = 1;
            for i = 1:nVectors
                vectorPrefix = sprintf('Vec%d_',i);
                vectorData = preallocate;
                vectorData(recoveredFlag,:) = [pointOutputData.T1(:,i),pointOutputData.T2(:,i),pointOutputData.T3(:,i)];
                vtkVector(index,1) = VtkVector(vectorData,[subcasePrefix,vectorPrefix,tType]);
                index = index+1;
                
                vectorData = preallocate;
                vectorData(recoveredFlag,:) = [pointOutputData.R1(:,i),pointOutputData.R2(:,i),pointOutputData.R3(:,i)];
                vtkVector(index,1) = VtkVector(vectorData,[subcasePrefix,vectorPrefix,rType]);
                index = index+1;
            end
        end
    end
end

