% Class that defines a static solution.
% Anthony Ricciardi
%
classdef static
    
    properties
        u_g
        u_0
        DB@db;
        SID; % Load case identification number
        displacement
    end
    
    methods 
        function obj=solve(obj,MODEL)
            obj.u_g=zeros(MODEL.ngdof,1);
            obj.u_0=zeros(MODEL.ngdof,1);
            
            if isempty(obj.SID); error('No load case identification number specified.'); end
            lc = find(obj.SID==MODEL.loadsSIDs);
            if isempty(lc); error('No applied loads found for this case.'); end
            
            f=MODEL.f;
            obj.u_g(f) = MODEL.K_g(f,f)\MODEL.p_g(f,lc);
            obj.u_0    = MODEL.R_0g*obj.u_g;
            
            % save node output data to node_output_data object
            obj.displacement = node_output_data.from_response(obj.u_0,MODEL.nodeIDs,1);
            
            % recover element quantities and save element output data
            
            
            
            %% Write output to FEMAP data blocks
            ID = 1;% [int] ID of output set
            title = 'Static Case 1'; % [max 79 char] Output Set title
            anal_type = 1; % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
            ProcessType = 0; % [int] Processing option for 'As Needed' Output Sets ( 0=None, 1=Linear Combination, 2=RSS Combination, 3=Max Envelope, 4=Min Envelope, 5=AbsMax Envelope, 6=Max Envelope SetID, 7=Min Envelope SetID, 8=AbsMax Envelope SetID)
            value = 0.0; % [real] Time or Frequency value for this case. 0.0 for static analysis.
            notes = 'Notes text. '; % [1xN char] One line of text.
            StudyID = 1; % [int] ID of Analysis Study
            nas_case = 0; % [int] Nastran SUBCASE ID associated with these results
            nas_rev = 0; % [int] Revision of Nastran SUBCASE
            
            obj.DB(1,1)=db450(ID,title,anal_type,ProcessType,value,notes,StudyID,nas_case,nas_rev);

                       
            obj.DB = [obj.DB;obj.displacement.write_db1051(ID)]
%             vecID = 1; % [int] ID of output vector, must be unique in each output set
%             
%             title = 'Total Translation'; % [max 79 char] Output Vector title
%             comp = [2,3,4,zeros(1,17)]; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
%             DoubleSidedContourVectorID = 0; % ?
%             
%             out_type = 1; % [int] Type of output (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
%             ent_type = 7; % [int] Either nodal (7) or elemental (8) output
%             compute_type = 0; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
%             
%             calc_warn = true; % [logical] If 1, can not linearly combine this output
%             comp_dir = 1; % [int] If 1, comp[0..2] are the X,Y,Z component values. If 2, data at end of Beams. If 3, reverse data at second end of beam.
%             cent_total = true; % [logical] If 1, this vector has centroidal or nodal output.
%             integer_format = false; % [logical] If True, vector contains integer rather than floating point results
%             
%             entityID =MODEL.nodeIDs;% [Nx1 int] Node/element IDs of the for results
%             value = sqrt(sum(obj.u_0( MODEL.node2gdof(1:3,:) ).^2)).'; % [Nx1 real] result values
%             
%             obj.DB(2,1)=db1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
%                 out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
%                 integer_format,entityID,value);
% 
%             calc_warn = false; % [logical] If 1, can not linearly combine this output
%             vecID = 2; % [int] ID of output vector, must be unique in each output set
%             title = 'T1 Translation'; % [max 79 char] Output Vector title
%             comp = [2,0,0,zeros(1,17)]; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
%             value = obj.u_0( MODEL.node2gdof(1,:) ); % [Nx1 real] result values
%             obj.DB(3,1)=db1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
%                 out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
%                 integer_format,entityID,value);
%             
%             vecID = 3; % [int] ID of output vector, must be unique in each output set
%             title = 'T2 Translation'; % [max 79 char] Output Vector title
%             comp = [0,3,0,zeros(1,17)]; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
%             value = obj.u_0( MODEL.node2gdof(2,:) ); % [Nx1 real] result values
%             obj.DB(4,1)=db1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
%                 out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
%                 integer_format,entityID,value);
%             
%             vecID = 4; % [int] ID of output vector, must be unique in each output set
%             title = 'T3 Translation'; % [max 79 char] Output Vector title
%             comp = [0,0,4,zeros(1,17)]; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
%             value = obj.u_0( MODEL.node2gdof(3,:) ); % [Nx1 real] result values
%             obj.DB(5,1)=db1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
%                 out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
%                 integer_format,entityID,value);
            
            ID = 1;
            Title = 'Analysis Study Title';
            Analysis_Type = 1;
            Analysis_Set = 1;
            Study_Notes = 'Study nodes';
            obj.DB(6,1) = db1056(ID,Title,Analysis_Type,Analysis_Set,Study_Notes);
            
            %% Write FEMAP data blocks to file
%             fid = fopen('myNeu.neu','w+');
            fid = 1;
            obj.DB.writeNeu_all(fid) ;
            fclose('all');
        end
    end
end

