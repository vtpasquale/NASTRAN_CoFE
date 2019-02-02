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
        femapOutputVectorTitles = {...
            'Total Translation','T1 Translation','T2 Translation','T3 Translation','Total Rotation','R1 Rotation','R2 Rotation','R3 Rotation';
            'Total Velocity','T1 Velocity','T2 Velocity','T3 Velocity','Total Ang Velocity','R1 Angular Velocity','R2 Angular Velocity','R3 Angular Velocity';
            'Total Acceleration','T1 Acceleration','T2 Acceleration','T3 Acceleration','Total Ang Acceleration','R1 Angular Acceleration','R2 Angular Acceleration','R3 Angular Acceleration';
            'Total Constraint Force','T1 Constraint Force','T2 Constraint Force','T3 Constraint Force','Total Constraint Moment','R1 Constraint Moment','R2 Constraint Moment','R3 Constraint Moment';
            'Total Applied Force','T1 Applied Force','T2 Applied Force','T3 Applied Force','Total Applied Moment','R1 Applied Moment','R2 Applied Moment','R3 Applied Moment';
            'Total Summed GPForce','T1 Summed GPForce','T2 Summed GPForce','T3 Summed GPForce','Total Summed GPMoment','R1 Summed GPMoment','R2 Summed GPMoment','R3 Summed GPMoment',
            }
        femapOutputVectorIDs = [...
            1:8   % DISPLACEMENT
            11:18 % VELOCITY
            21:28 % ACCELERATION
            51:58 % SPC FORCES
            41:48 % Applied Force
            161:168 % Summed GPForce
            ];
        femapOutputType = [... % (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
            1 % DISPLACEMENT
            2 % VELOCITY
            2 % ACCELERATION
            3 % SPC FORCE
            3 % Applied Force
            3 % Summed GPForce
            ];
    end
    methods
        function obj = PointOutputData(responseType,response,model,keepIndex)
            % Constructs NodeOutputData object from response vectors
            % Inputs:
            %   responseType [uint8] NodeOutputData.responseType -> integer specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
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
            
            % Initialize NodeOutputData object
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
            if isnumeric(in)==0; error('NodeOutputData.responseType must be a number'); end
            if mod(in,1) ~= 0; error('NodeOutputData.responseType must be an integer'); end
            if in < 1 || in > 5; error('NodeOutputData.responseType must be greater than zero and less than 6.'); end
            obj.responseType=uint8(in);
        end
        function echo(obj,fid)
            dispString = sprintf('\n\n%s\n',PointOutputData.printTitles{obj.responseType});
            nResponseVectors = size(obj.T1,2);
            sFormat = sprintf('%%14d      %c   %%15E%%15E%%15E%%15E%%15E%%15E\\n',obj.pointType);
            for i = 1:nResponseVectors
                fprintf(fid,'%s',dispString);
                fprintf(fid,'\n      POINT ID.   TYPE          T1             T2             T3             R1             R2             R3\n');
                fprintf(fid,sFormat,[double(obj.ID),obj.T1(:,i),obj.T2(:,i),obj.T3(:,i),obj.R1(:,i),obj.R2(:,i),obj.R3(:,i)]' );
            end
        end
        function femapDataBlock1051 = convert_2_FemapDataBlock1051(obj,startSetID)
            femapDataBlock1051 = [];
            DoubleSidedContourVectorID = 0;
            out_type = NodeOutputData.femapOutputType(obj.responseType); % [int] Type of output (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
            ent_type = 7; % [int] Either nodal (7) or elemental (8) output\                compute_type = 0; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
            compute_type = 0; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
            comp_dir = 1; % [int] If 1, comp[0..2] are the X,Y,Z component values. If 2, data at end of Beams. If 3, reverse data at second end of beam.
            cent_total = true; % [logical] If 1, this vector has centroidal or nodal output.
            integer_format = false; % [logical] If True, vector contains integer rather than floating point results
            
            vecID = NodeOutputData.femapOutputVectorIDs(obj.responseType,:); % [int] ID of output vector, must be unique in each output set
            title = NodeOutputData.femapOutputVectorTitles(obj.responseType,:); % [max 79 char] Output Vector title
            comp = zeros(8,20);
            comp(1,1:3) = vecID(1:3);
            comp(2,1) = vecID(1);
            comp(3,2) = vecID(2);
            comp(4,3) = vecID(3);
            comp(5,1:3) = vecID(6:8);
            comp(6,1) = vecID(6);
            comp(7,2) = vecID(7);
            comp(8,3) = vecID(8);
            calc_warn = [true false false false true false false false]; % [logical] If 1, can not linearly combine this output
            
            entityID =obj.ID;% [Nx1 int] Node/element IDs of the for results
            
            TT = sqrt(obj.T1.^2 + obj.T2.^2 + obj.T3.^2);
            RT = sqrt(obj.R1.^2 + obj.R2.^2 + obj.R3.^2);
            
            nResponseVectors = size(obj.T1,2);
            for i = 1:nResponseVectors
                setID = startSetID+i-1;

                % Total Linear
                femapDataBlock1051=[femapDataBlock1051;FemapDataBlock1051(...
                    setID,vecID(1),title{1},comp(1,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(1),comp_dir,cent_total,...
                    integer_format,entityID,...
                    TT(:,i))];
                
                % T1
                femapDataBlock1051=[femapDataBlock1051;FemapDataBlock1051(...
                    setID,vecID(2),title{2},comp(2,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(2),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.T1(:,i))];
                
                % T2
                femapDataBlock1051=[femapDataBlock1051;FemapDataBlock1051(...
                    setID,vecID(3),title{3},comp(3,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(3),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.T2(:,i))];
                
                % T3
                femapDataBlock1051=[femapDataBlock1051;FemapDataBlock1051(...
                    setID,vecID(4),title{4},comp(4,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(4),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.T3(:,i))];
                
                % Total Rotational
                femapDataBlock1051=[femapDataBlock1051;FemapDataBlock1051(...
                    setID,vecID(5),title{5},comp(5,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(5),comp_dir,cent_total,...
                    integer_format,entityID,...
                    RT(:,i))];
                
                % R1
                femapDataBlock1051=[femapDataBlock1051;FemapDataBlock1051(...
                    setID,vecID(6),title{6},comp(6,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(6),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.R1(:,i))];
                
                % R2
                femapDataBlock1051=[femapDataBlock1051;FemapDataBlock1051(...
                    setID,vecID(7),title{7},comp(7,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(7),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.R2(:,i))];
                
                % R3
                femapDataBlock1051=[femapDataBlock1051;FemapDataBlock1051(...
                    setID,vecID(8),title{8},comp(8,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(8),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.R3(:,i))];
                
                setID = setID+1;
            end
        end
    end
end
