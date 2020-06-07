% Class for output data at grid points and scalar points
% Anthony Ricciardi
%
classdef PointOutputData
    
    properties
        responseType  % [uint8] CoFE code specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
        ID % [nOutputPoints,1] Output point ID numbers
        pointType % [nOutputPoints,1 char] Point type: 'G' for grid point 'S' for scalar point 
        T1 % [nOutputPoints,nResponseVectors] X translation response - or scalar point response
        T2 % [nOutputPoints,nResponseVectors] Y translation response
        T3 % [nOutputPoints,nResponseVectors] Z translation response
        R1 % [nOutputPoints,nResponseVectors] X rotation response
        R2 % [nOutputPoints,nResponseVectors] Y rotation response
        R3 % [nOutputPoints,nResponseVectors] Z rotation response
    end
    properties (Constant = true, Hidden = true)
        printTitles = {...
            '                                         D I S P L A C E M E N T S';
            '                                            V E L O C I T I E S';
            '                                         A C C E L E R A T I O N S';
            '                       S I N G L E    P O I N T    C O N S T R A I N T    F O R C E S';
            '                                       A P P L I E D    F O R C E S';
            '                            S U M M E D    G R I D    P O I N T    F O R C E S';
            }
    end
    methods
        function obj = PointOutputData(responseType,response,model,keepIndex)
            % Constructs PointOutputData object from response vectors
            % Inputs:
            %   responseType [uint8] PointOutputData.responseType -> integer specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
            %   response [nGdof,nResponseVectors] matrix of response vectors
            %   model [model] model object
            %   keepIndex [nOutputPoints,1] Optional vector of indicies for output points in ID --> PointOutputData.ID=ID(keepIndex);
            
            % check inputs
            if nargin < 3; error('Not enought input arguments.'); end
            [nResponse,mResponse]=size(response);
            if nResponse < 1 || mResponse < 1; error('Input u matrix of response vectors size [nGdof,nResponseVectors]'); end
            [nPoints,mPoints]=size(model.point);
            if nPoints < 1 || mPoints ~= 1; error('Input model.points should be size [n,1].'); end
            if nPoints>nResponse; error('Input inconsistency: nPoints > nResponse)'); end
            if nargin > 3
                [nKid,mKid]=size(keepIndex);
                if nPoints < nKid || mKid ~= 1; error('Optional input keepIndex should be a vector of integer size [n,1].'); end
            end
            
            % Initialize PointOutputData object
            obj.responseType = responseType;
            
            % process
            if nargin < 4
                % keep all points
                obj.ID = model.pointIDs;
                nKeepPoint = nPoints;
                keepNodeFlag = model.nodeFlag;
                keepModelPoint = model.point;
            else
                % keep select points
                obj.ID = model.pointIDs(keepIndex);
                nKeepPoint = nKid;
                keepNodeFlag = model.nodeFlag(keepIndex);
                keepModelPoint = model.point(keepIndex);
            end
            
            % assign point types
            obj.pointType = repmat('G',[nKeepPoint,1]);
            obj.pointType(~keepNodeFlag)='S';
            
            % preallocate response variables
            obj.T1=zeros(nKeepPoint,mResponse);
            obj.T2=obj.T1;
            obj.T3=obj.T1;
            obj.R1=obj.T1;
            obj.R2=obj.T1;
            obj.R3=obj.T1;
            
            % save response at requested nodes
            if any(keepNodeFlag)
                node = keepModelPoint(keepNodeFlag);
                nodeGdof = [node.gdof];
                obj.T1(keepNodeFlag,:)=response(nodeGdof(1:6:end),:);
                obj.T2(keepNodeFlag,:)=response(nodeGdof(2:6:end),:);
                obj.T3(keepNodeFlag,:)=response(nodeGdof(3:6:end),:);
                obj.R1(keepNodeFlag,:)=response(nodeGdof(4:6:end),:);
                obj.R2(keepNodeFlag,:)=response(nodeGdof(5:6:end),:);
                obj.R3(keepNodeFlag,:)=response(nodeGdof(6:6:end),:);
            end
            
            % save response at requested scalar points
            if any(~keepNodeFlag)
                scalarPoint = keepModelPoint(~keepNodeFlag);
                scalarPointGdof = [scalarPoint.gdof];
                obj.T1(~keepNodeFlag,:)=response(scalarPointGdof,:);
            end
        end
        function obj = set.responseType(obj,in)
            if isnumeric(in)==0; error('PointOutputData.responseType must be a number'); end
            if mod(in,1) ~= 0; error('PointOutputData.responseType must be an integer'); end
            if in < 1 || in > 5; error('PointOutputData.responseType must be greater than zero and less than 6.'); end
            obj.responseType=uint8(in);
        end
        function printTextOutput(obj,fid,outputHeading)
            dispString = sprintf('%s\n',PointOutputData.printTitles{obj.responseType});
            nResponseVectors = size(obj.T1,2);
            sFormat = sprintf('%%14d      %c   %%15E%%15E%%15E%%15E%%15E%%15E\\n',obj.pointType);
            for i = 1:nResponseVectors
                if nargin > 2
                    outputHeading.printTextOutput(fid,i)
                end
                fprintf(fid,'%s',dispString);
                fprintf(fid,'\n      POINT ID.   TYPE          T1             T2             T3             R1             R2             R3\n');
                fprintf(fid,sFormat,[double(obj.ID),obj.T1(:,i),obj.T2(:,i),obj.T3(:,i),obj.R1(:,i),obj.R2(:,i),obj.R3(:,i)]' );
            end
        end
    end
end
