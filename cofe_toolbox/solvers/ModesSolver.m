% Class that defines a normal modes analysis.
% Anthony Ricciardi
%
classdef ModesSolver < Solver
    
    properties
        u_g
        u_0
        f_g
        f_0
        
        eigenvalueTable
        
        displacement_0
        displacement_g
%         velocity_0
%         velocity_g
%         acceleration_0
%         acceleration_g
        spcforces_0
        spcforces_g
        
        force
        stress
        strain
        strainEnergy
        
        femapDataBlock
    end
    
    methods 
        function obj=solve_sub(obj,caseControl,model)
            
            % process EIGRL
            if isempty(caseControl.method); error('No METHOD defined in Case Control section.'); end
            nModes = model.eigrl(caseControl.method==model.eigrl(:,1),2);
            if isempty(nModes); error('EIGRL method is undefined. Check case control METHOD ID and bulk data EIGRL ID.'); error(''); end
            
            % sets
            f=model.f;
            s=model.s;
            
            if nModes>sum(f)
                nModes=sum(f);
                warning('The number of modes requested by the EIGRL input is larger than the independent set - the number of modes recovered will be less than requested.')
            end
            
            % preallocate
            obj.u_g=zeros(model.ngdof,nModes);
            obj.u_0=zeros(model.ngdof,nModes);
            
            %% Solve
            
            % modes
            Ka = model.K_g(f,f);
            Ma = model.M_g(f,f);
            [V,D] = eigs(Ka,Ma,nModes);
            eigenvalues = diag(D);
            
            % mass normalize eigenvectors (required for Lee and Jung sensitivity method)
            for mn = 1:nModes
                % Complication: eigenvectors are reversable. 
                % This can be a problem for sensitivity methods.
                % This is an attempt to keep eigenvector directions 
                % consistent across design cycles.
                if sum(V(:,mn)) < 0
                    V(:,mn) = -V(:,mn);
                end
                
                % Mass normalize
                V(:,mn) = V(:,mn)./sqrt(V(:,mn).'*Ma*V(:,mn));
            end
            
            %           
            obj.eigenvalueTable = EigenvalueTable(eigenvalues,diag(V.'*Ma*V),diag(V.'*Ka*V));
            
            obj.u_g(f,:)= V;
            obj.u_0     = model.R_0g*obj.u_g;
            
            % constraint forces
            obj.f_g = zeros(size(obj.u_g));
            obj.f_g(s,:) = model.K_g(s,f)*obj.u_g(f,:) + model.K_g(s,s)*obj.u_g(s,:);
            obj.f_0 = model.R_0g*obj.f_g;
            
            % recover and store selected response data at nodes and elements 
            obj = model.node.recover(obj,caseControl,model.nodeIDs);
            obj = model.element.recover(obj,caseControl);
        end
        function obj = output_sub(obj,caseControl,writeFemapFlag,fid)
            
            % Print Eigenvalue table
            obj.eigenvalueTable.echo(fid)
            
            % Output select results
            if caseControl.displacement.n~=0
                if caseControl.displacement.print==true
                    obj.displacement_g.echo(fid) % To text output file
                end
                if writeFemapFlag
                    obj.femapDataBlock = [obj.femapDataBlock;convert_2_FemapDataBlock1051(obj.displacement_0,1)];
                end
            end
        end
        
%             %% Output results data
% 
%             % Write output to FEMAP data blocks
%             ID = 1;% [int] ID of output set
%             title = 'Static Case 1'; % [max 79 char] Output Set title
%             anal_type = 1; % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
%             ProcessType = 0; % [int] Processing option for 'As Needed' Output Sets ( 0=None, 1=Linear Combination, 2=RSS Combination, 3=Max Envelope, 4=Min Envelope, 5=AbsMax Envelope, 6=Max Envelope SetID, 7=Min Envelope SetID, 8=AbsMax Envelope SetID)
%             value = 0.0; % [real] Time or Frequency value for this case. 0.0 for static analysis.
%             notes = 'Notes text. '; % [1xN char] One line of text.
%             StudyID = 1; % [int] ID of Analysis Study
%             nas_case = caseControl.ID; % [int] Nastran SUBCASE ID associated with these results
%             nas_rev = 0; % [int] Revision of Nastran SUBCASE
%             
%             obj.femapDataBlock(1,1)=FemapDataBlock450(ID,title,anal_type,ProcessType,value,notes,StudyID,nas_case,nas_rev);
%                        
%             obj.femapDataBlock = [obj.femapDataBlock;obj.displacement_0.convert_2_FemapDataBlock1051(ID)];
%             obj.femapDataBlock = [obj.femapDataBlock;obj.force.convert_2_FemapDataBlock1051(model,ID)];
%             obj.femapDataBlock = [obj.femapDataBlock;obj.stress.convert_2_FemapDataBlock1051(model,ID)];
%             
%             ID = 1;
%             Title = 'Analysis Study Title';
%             Analysis_Type = 1;
%             Analysis_Set = 1;
%             Study_Notes = 'Study nodes';
%             obj.femapDataBlock(6,1) = FemapDataBlock1056(ID,Title,Analysis_Type,Analysis_Set,Study_Notes);
%             
            % Write FEMAP data blocks to file
%             fid = 1;
%             obj.femapDataBlock.writeNeutral(fid) ;
%             fclose('all');
    end
end

