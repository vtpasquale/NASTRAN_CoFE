% Class for output data at nodes
% Anthony Ricciardi
%
classdef node_output_data
    
    properties
        response_type  % [uint8] CoFE code specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
        ID % [n_out_nodes,1] Output node ID numbers
        T1 % [n_out_nodes,n_response_vectors] X translation response
        T2 % [n_out_nodes,n_response_vectors] Y translation response
        T3 % [n_out_nodes,n_response_vectors] Z translation response
        R1 % [n_out_nodes,n_response_vectors] X rotation response
        R2 % [n_out_nodes,n_response_vectors] Y rotation response
        R3 % [n_out_nodes,n_response_vectors] Z rotation response
    end
    properties (Constant = true, Hidden = true)
        print_titles = {...
            '                                                 D I S P L A C E M E N T S';
            '                                                    V E L O C I T I E S';
            '                                                 A C C E L E R A T I O N S';
            '                                               A P P L I E D    F O R C E S';
            '                                    S U M M E D    G R I D    P O I N T    F O R C E S';
            }
        femap_output_vector_titles = {...
            'Total Translation','T1 Translation','T2 Translation','T3 Translation','Total Rotation','R1 Rotation','R2 Rotation','R3 Rotation';
            'Total Velocity','T1 Velocity','T2 Velocity','T3 Velocity','Total Ang Velocity','R1 Angular Velocity','R2 Angular Velocity','R3 Angular Velocity';
            'Total Acceleration','T1 Acceleration','T2 Acceleration','T3 Acceleration','Total Ang Acceleration','R1 Angular Acceleration','R2 Angular Acceleration','R3 Angular Acceleration';
            'Total Constraint Force','T1 Constraint Force','T2 Constraint Force','T3 Constraint Force','Total Constraint Moment','R1 Constraint Moment','R2 Constraint Moment','R3 Constraint Moment';
            'Total Applied Force','T1 Applied Force','T2 Applied Force','T3 Applied Force','Total Applied Moment','R1 Applied Moment','R2 Applied Moment','R3 Applied Moment';
            'Total Summed GPForce','T1 Summed GPForce','T2 Summed GPForce','T3 Summed GPForce','Total Summed GPMoment','R1 Summed GPMoment','R2 Summed GPMoment','R3 Summed GPMoment',
            }
        femap_output_vector_IDs = [...
            1:8   % DISPLACEMENT
            11:18 % VELOCITY
            21:28 % ACCELERATION
            51:58 % SPC FORCE
            41:48 % Applied Force
            161:168 % Summed GPForce
            ];
        femap_output_type = [... % (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
            1 % DISPLACEMENT
            2 % VELOCITY
            2 % ACCELERATION
            3 % SPC FORCE
            3 % Applied Force
            3 % Summed GPForce
            ];
    end
    methods(Static = true)
        function node_output = from_response(response_type,resp,ID,keep_ind)
            % Instantiates a node_output_data object from response vectors
            % Inputs:
            %   response_type [uint8] node_output_data.response_type -> integer specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
            %   resp [6*n_nodes,n_response_vectors] matrix of response vectors
            %   ID [n_nodes,1] vector of all node ID numbers
            %   keep_ind [n_output_nodes,1] Optional vector of indicies for output nodes in ID --> node_output_data.ID=ID(keep_ind);
            
            % check inputs
            if nargin < 3; error('Not enought input arguments.'); end
            [nu,mu]=size(resp);
            if nu < 1 || mu < 1; error('Input u matrix of response vectors size [6*n_nodes,n_response_vectors]'); end
            [nID,mID]=size(ID);
            if nID < 1 || mID ~= 1; error('Input ID should be a vector of integer size [n,1].'); end
            if 6*nID~=nu; error('Input inconsistency: size(u,1)~=6*size(ID,1)'); end
            if nargin > 3
                [n_kid,m_kid]=size(keep_ind);
                if nID < n_kid || m_kid ~= 1; error('Optional input keep_ind should be a vector of integer size [n,1].'); end
            end
            
            % Initialize node_output_data object
            node_output = node_output_data;
            node_output.response_type = response_type;
            
            % process
            if nargin < 4
                % keep all
                node_output.ID=ID;
                node_output.T1=resp(1:6:end,:);
                node_output.T2=resp(2:6:end,:);
                node_output.T3=resp(3:6:end,:);
                node_output.R1=resp(4:6:end,:);
                node_output.R2=resp(5:6:end,:);
                node_output.R3=resp(6:6:end,:);
            else
                % downselect
                index_all = uint32(1:6:size(resp,1)).';
                index = index_all(keep_ind);
                node_output.ID=ID(keep_ind);
                node_output.T1=resp(index  ,:);
                node_output.T2=resp(index+1,:);
                node_output.T3=resp(index+2,:);
                node_output.R1=resp(index+3,:);
                node_output.R2=resp(index+4,:);
                node_output.R3=resp(index+5,:);
            end
        end
    end
    methods
        function obj = set.response_type(obj,in)
            if isnumeric(in)==0; error('node_output_data.response_type must be a number'); end
            if mod(in,1) ~= 0; error('node_output_data.response_type must be an integer'); end
            if in < 1 || in > 5; error('node_output_data.response_type must be greater than zero and less than 6.'); end
            obj.response_type=uint8(in);
        end
        function echo(obj,fid)
            disp_string = sprintf('\n\n%s\n',node_output_data.print_titles{obj.response_type});
            n_response_vectors = size(obj.T1,2);
            for i = 1:n_response_vectors
                fprintf(fid,'%s',disp_string);
                fprintf(fid,'\n   GRID ID.            T1             T2               T3             R1               R2             R3\n');
                fprintf(fid,' %8d \t\t %+E \t %+E \t %+E \t %+E \t %+E \t %+E \n',[double(obj.ID),obj.T1(:,i),obj.T2(:,i),obj.T3(:,i),obj.R1(:,i),obj.R2(:,i),obj.R3(:,i)]' );
            end
        end
        function DB = convert_2_db1051(obj,startSetID)
            DB = [];
            DoubleSidedContourVectorID = 0;
            out_type = node_output_data.femap_output_type(obj.response_type); % [int] Type of output (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
            ent_type = 7; % [int] Either nodal (7) or elemental (8) output\                compute_type = 0; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
            compute_type = 0; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
            comp_dir = 1; % [int] If 1, comp[0..2] are the X,Y,Z component values. If 2, data at end of Beams. If 3, reverse data at second end of beam.
            cent_total = true; % [logical] If 1, this vector has centroidal or nodal output.
            integer_format = false; % [logical] If True, vector contains integer rather than floating point results
            
            vecID = node_output_data.femap_output_vector_IDs(obj.response_type,:); % [int] ID of output vector, must be unique in each output set
            title = node_output_data.femap_output_vector_titles(obj.response_type,:); % [max 79 char] Output Vector title
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
            
            n_response_vectors = size(obj.T1,2);
            for i = 1:n_response_vectors
                setID = startSetID+i-1;

                % Total Linear
                DB=[DB;db1051(setID,vecID(1),title{1},comp(1,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(1),comp_dir,cent_total,...
                    integer_format,entityID,...
                    TT(:,i))];
                
                % T1
                DB=[DB;db1051(setID,vecID(2),title{2},comp(2,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(2),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.T1(:,i))];
                
                % T2
                DB=[DB;db1051(setID,vecID(3),title{3},comp(3,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(3),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.T2(:,i))];
                
                % T3
                DB=[DB;db1051(setID,vecID(4),title{4},comp(4,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(4),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.T3(:,i))];
                
                % Total Rotational
                DB=[DB;db1051(setID,vecID(5),title{5},comp(5,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(5),comp_dir,cent_total,...
                    integer_format,entityID,...
                    RT(:,i))];
                
                % R1
                DB=[DB;db1051(setID,vecID(6),title{6},comp(6,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(6),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.R1(:,i))];
                
                % R2
                DB=[DB;db1051(setID,vecID(7),title{7},comp(7,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(7),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.R2(:,i))];
                
                % R3
                DB=[DB;db1051(setID,vecID(8),title{8},comp(8,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn(8),comp_dir,cent_total,...
                    integer_format,entityID,...
                    obj.R3(:,i))];
                
                setID = setID+1;
            end
        end
    end
end
