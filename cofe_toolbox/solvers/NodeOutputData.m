% Class for output data at nodes
% Anthony Ricciardi
%
classdef NodeOutputData
    
    properties
        responseType  % [uint8] CoFE code specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
        ID % [nOutputNodes,1] Output node ID numbers
        T1 % [nOutputNodes,nResponseVectors] X translation response
        T2 % [nOutputNodes,nResponseVectors] Y translation response
        T3 % [nOutputNodes,nResponseVectors] Z translation response
        R1 % [nOutputNodes,nResponseVectors] X rotation response
        R2 % [nOutputNodes,nResponseVectors] Y rotation response
        R3 % [nOutputNodes,nResponseVectors] Z rotation response
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
        function obj = NodeOutputData(responseType,response,ID,keepIndex)
            % Constructs NodeOutputData object from response vectors
            % Inputs:
            %   responseType [uint8] NodeOutputData.responseType -> integer specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
            %   response [6*nNodes,nResponseVectors] matrix of response vectors
            %   ID [nNodes,1] vector of all node ID numbers
            %   keepIndex [nOutputNodes,1] Optional vector of indicies for output nodes in ID --> NodeOutputData.ID=ID(keep_ind);
            
            % check inputs
            if nargin < 3; error('Not enought input arguments.'); end
            [nu,mu]=size(response);
            if nu < 1 || mu < 1; error('Input u matrix of response vectors size [6*n_nodes,nResponseVectors]'); end
            [nID,mID]=size(ID);
            if nID < 1 || mID ~= 1; error('Input ID should be a vector of integer size [n,1].'); end
            if 6*nID~=nu; error('Input inconsistency: size(u,1)~=6*size(ID,1)'); end
            if nargin > 3
                [n_kid,m_kid]=size(keepIndex);
                if nID < n_kid || m_kid ~= 1; error('Optional input keep_ind should be a vector of integer size [n,1].'); end
            end
            
            % Initialize NodeOutputData object
            obj.responseType = responseType;
            
            % process
            if nargin < 4
                % keep all
                obj.ID=ID;
                obj.T1=response(1:6:end,:);
                obj.T2=response(2:6:end,:);
                obj.T3=response(3:6:end,:);
                obj.R1=response(4:6:end,:);
                obj.R2=response(5:6:end,:);
                obj.R3=response(6:6:end,:);
            else
                % downselect
                index_all = uint32(1:6:size(response,1)).';
                index = index_all(keepIndex);
                obj.ID=ID(keepIndex);
                obj.T1=response(index  ,:);
                obj.T2=response(index+1,:);
                obj.T3=response(index+2,:);
                obj.R1=response(index+3,:);
                obj.R2=response(index+4,:);
                obj.R3=response(index+5,:);
            end
        end
        function obj = set.responseType(obj,in)
            if isnumeric(in)==0; error('NodeOutputData.responseType must be a number'); end
            if mod(in,1) ~= 0; error('NodeOutputData.responseType must be an integer'); end
            if in < 1 || in > 5; error('NodeOutputData.responseType must be greater than zero and less than 6.'); end
            obj.responseType=uint8(in);
        end
        function echo(obj,fid)
            dispString = sprintf('\n\n%s\n',NodeOutputData.printTitles{obj.responseType});
            nResponseVectors = size(obj.T1,2);
            for i = 1:nResponseVectors
                fprintf(fid,'%s',dispString);
                fprintf(fid,'\n       GRID ID.       T1             T2             T3             R1             R2             R3\n');
                fprintf(fid,'%14d%15E%15E%15E%15E%15E%15E\n',[double(obj.ID),obj.T1(:,i),obj.T2(:,i),obj.T3(:,i),obj.R1(:,i),obj.R2(:,i),obj.R3(:,i)]' );
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
