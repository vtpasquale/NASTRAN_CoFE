% Class that defines a static solution.
% Anthony Ricciardi
%
classdef Static
    
    properties
        u_g
        u_0
        DB@db;
        displacement_0
        displacement_g
        force
        stress
        strain
        strain_energy
    end
    
    methods 
        function obj=solve(obj,caseControl,model)
            obj.u_g=zeros(model.ngdof,1);
            obj.u_0=zeros(model.ngdof,1);
            
            if isempty(caseControl.load); error('No load case identification number specified.'); end
            lc = find(caseControl.load==model.loadSIDs);
            if isempty(lc); error('No applied loads found for this case.'); end
            
            f=model.f;
            obj.u_g(f) = model.K_g(f,f)\model.p_g(f,lc);
            obj.u_0    = model.R_0g*obj.u_g;
            
%             % fake multiple response vectors for testing
%             obj.u_0 = [obj.u_0,2*obj.u_0,5*obj.u_0];
%             obj.u_g = [obj.u_g,2*obj.u_g,5*obj.u_g];
            
            %%
            % save node output data to node_output_data objects
            if caseControl.displacement.n ~= 0
                responseType = 1; % 1=displacement
                ID = model.nodeIDs;
                keepIndex = caseControl.displacement.getRequestMemberIndices(ID,caseControl.outputSet);
                
                response = obj.u_0;
                obj.displacement_0 = NodeOutputData(responseType,response,ID,keepIndex);
                
                response = obj.u_g;
                obj.displacement_g = NodeOutputData(responseType,response,ID,keepIndex);
                clear responseType response ID keepIndex
            end
            
% 
%             
%             % recover element quantities and save element output data
%             obj = model.ELEM.recover(obj);
%             
%             
%             %% Write output to FEMAP data blocks
%             ID = 1;% [int] ID of output set
%             title = 'Static Case 1'; % [max 79 char] Output Set title
%             anal_type = 1; % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
%             ProcessType = 0; % [int] Processing option for 'As Needed' Output Sets ( 0=None, 1=Linear Combination, 2=RSS Combination, 3=Max Envelope, 4=Min Envelope, 5=AbsMax Envelope, 6=Max Envelope SetID, 7=Min Envelope SetID, 8=AbsMax Envelope SetID)
%             value = 0.0; % [real] Time or Frequency value for this case. 0.0 for static analysis.
%             notes = 'Notes text. '; % [1xN char] One line of text.
%             StudyID = 1; % [int] ID of Analysis Study
%             nas_case = 0; % [int] Nastran SUBCASE ID associated with these results
%             nas_rev = 0; % [int] Revision of Nastran SUBCASE
%             
%             obj.DB(1,1)=db450(ID,title,anal_type,ProcessType,value,notes,StudyID,nas_case,nas_rev);
%                        
%             obj.DB = [obj.DB;obj.displacement_0.convert_2_db1051(ID)];
%             obj.DB = [obj.DB;obj.force.convert_2_db1051(model,ID)];
%             obj.DB = [obj.DB;obj.stress.convert_2_db1051(model,ID)];
%             
%             ID = 1;
%             Title = 'Analysis Study Title';
%             Analysis_Type = 1;
%             Analysis_Set = 1;
%             Study_Notes = 'Study nodes';
%             obj.DB(6,1) = db1056(ID,Title,Analysis_Type,Analysis_Set,Study_Notes);
%             
%             %% Write FEMAP data blocks to file
% %             fid = fopen('myNeu.neu','w+');
%             fid = 1;
%             obj.DB.writeNeu_all(fid) ;
%             fclose('all');
        end
    end
end

