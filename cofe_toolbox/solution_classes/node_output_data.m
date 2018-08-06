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
    properties (Dependent = true, Hidden = true)
        femap_out_type
        femap_title
    end
    methods
        function femap_out_type = get.femap_out_type(obj);
            switch obj.response_type
                case 1
                    femap_out_type = 1;
                case 2
                    femap_out_type = 0;
                case 3 
                    femap_out_type = 2;
            end
        end
        function femap_title = get.femap_title(obj);
            switch obj.response_type
                case 1
                    femap_title = 'Translation';
                case 2
                    femap_title = 'Velocity';
                case 3 
                    femap_title = 'Acceleration';
                otherwise
                    femap_title = '';
            end
        end
    end
    methods(Static = true)
        function node_output = from_response(resp,ID,response_type,keep_ind)
            % Instantiates a node_output_data object from response vectors
            % Inputs:
            %   resp [6*n_nodes,n_response_vectors] matrix of response vectors
            %   ID [n_nodes,1] vector of all node ID numbers
            %   response_type [uint8] node_output_data.response_type -> CoFE code specifying response type [1=DISPLACEMENT,2=VELOCITY,3=ACCELERATION,4=SPC FORCE]
            %   keep_ind [n_output_nodes,1] Vector of indicies for output nodes in ID --> node_output_data.ID=ID(keep_ind);
            
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
            if in < 1 || in > 4; error('node_output_data.response_type must be greater than zero and less than 5.'); end
            obj.response_type=uint8(in);
        end
        function echo(obj,fid)
            % choose display string based on response type
            if ~isempty(obj.response_type)
                switch obj.response_type
                    case 1
                        disp_string = sprintf('\n\n                                                 D I S P L A C E M E N T S\n');
                    case 2
                        disp_string = sprintf('\n\n                                                    V E L O C I T I E S\n');
                    case 3
                        disp_string = sprintf('\n\n                                                 A C C E L E R A T I O N S\n');
                end
            end
            n_response_vectors = size(obj.T1,2);
            for i = 1:n_response_vectors
                fprintf(fid,'%s',disp_string);
                fprintf(fid,'\n   GRID ID.            T1             T2               T3             R1               R2             R3\n');
                fprintf(fid,' %8d \t\t %+E \t %+E \t %+E \t %+E \t %+E \t %+E \n',[double(obj.ID),obj.T1(:,i),obj.T2(:,i),obj.T3(:,i),obj.R1(:,i),obj.R2(:,i),obj.R3(:,i)]' );
            end
        end
        function DB = write_db1051(obj,startSetID)
            DB = [];
            setID = startSetID;
            DoubleSidedContourVectorID = 0;
            out_type = obj.femap_out_type; % [int] Type of output (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
            ent_type = 7; % [int] Either nodal (7) or elemental (8) output
            comp_dir = 1; % [int] If 1, comp[0..2] are the X,Y,Z component values. If 2, data at end of Beams. If 3, reverse data at second end of beam.
            cent_total = true; % [logical] If 1, this vector has centroidal or nodal output.
            integer_format = false; % [logical] If True, vector contains integer rather than floating point results
            
            TT = sqrt(obj.T1.^2 + obj.T2.^2 + obj.T3.^2);
            RT = sqrt(obj.R1.^2 + obj.R2.^2 + obj.R3.^2);
            
            n_response_vectors = size(obj.T1,2);
            for i = 1:n_response_vectors
                
                vecID = 1; % [int] ID of output vector, must be unique in each output set
                title = ['Total',obj.femap_title]; % [max 79 char] Output Vector title
                comp = [2,3,4,zeros(1,17)]; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
                compute_type = 0; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
                calc_warn = true; % [logical] If 1, can not linearly combine this output
                entityID =obj.ID;% [Nx1 int] Node/element IDs of the for results
                value = TT(:,i); % [Nx1 real] result values
                
                DB=[DB;db1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                    integer_format,entityID,value)];
                
                calc_warn = false; % [logical] If 1, can not linearly combine this output
                vecID = 2; % [int] ID of output vector, must be unique in each output set
                title = 'T1 Translation'; % [max 79 char] Output Vector title
                comp = [2,0,0,zeros(1,17)]; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
                value = obj.T1(:,i); % [Nx1 real] result values
                DB=[DB;db1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                    integer_format,entityID,value)];
                
                vecID = 3; % [int] ID of output vector, must be unique in each output set
                title = 'T2 Translation'; % [max 79 char] Output Vector title
                comp = [0,3,0,zeros(1,17)]; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
                value = obj.T2(:,i); % [Nx1 real] result values
                DB=[DB;db1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                    integer_format,entityID,value)];
                
                vecID = 4; % [int] ID of output vector, must be unique in each output set
                title = 'T3 Translation'; % [max 79 char] Output Vector title
                comp = [0,0,4,zeros(1,17)]; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
                value = obj.T3(:,i); % [Nx1 real] result values
                DB=[DB;db1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                    integer_format,entityID,value)];
                
                setID = setID+1;
            end
        end
    end
end
