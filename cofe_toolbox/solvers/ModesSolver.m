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
        function obj=solve_sub(obj,model)
            % Normal modes solution
            %
            % INPUTS
            % obj = [1,nSuperElements ModesSolver] Array of ModesSolver objects, one for each superelement
            % model = [nSuperElements,1 Model] Array of Model Objects, one for each superelement
            % caseControlIndex = [double] Case control (subcase) index number
            
            model0 = model(1); % Residual structure
            
            % process EIGRL
            nModes = model0.getNumModes();
            
%             % sets
%             f=model.f;
%             s=model.s;
                       
%             % preallocate
%             obj.u_g=zeros(model.nGdof,nModes);
%             obj.u_0=zeros(model.nGdof,nModes);
            
            %% Solve
            K_aa = model0.K_aa;
            M_aa = model0.M_aa;
            
            nAset = size(K_aa,1);
            if nModes>nAset
                nModes=nAset;
                warning('The number of modes requested by the EIGRL input is larger than the analysis set - the number of modes recovered will be less than requested.')
            end
            [u_a,D] = eigs(M_aa,K_aa,nModes); % -> (1/w^2) * K * V = M * V is more reliable than K * V = w^2 * M * V
            eigenvalues = diag(D).^-1;
            
            % Sort by eigenvalue (eigs() does not always return sorted eigenvalues and eigenvectors)
            [eigenvalues,index]=sort(eigenvalues);
            u_a = u_a(:,index);
            
            % mass normalize eigenvectors
            u_a = u_a./repmat(sqrt(diag(u_a.'*M_aa*u_a)).',[nAset,1]);
            
            % Eigenvalue table
            obj(1).eigenvalueTable = EigenvalueTable(eigenvalues,diag(u_a.'*M_aa*u_a),diag(u_a.'*K_aa*u_a));
            
            % Expand eigenvectors
%             obj = model.modelExpansion(obj,u_a);
            
%             obj.u_g(f,:)= V;
%             obj(1).u_0     = model0.R_0g*obj(1).u_g;
%             
%             % constraint forces
%             obj.f_g = zeros(size(obj.u_g));
%             obj.f_g(s,:) = model.K_gg(s,f)*obj.u_g(f,:) + model.K_gg(s,s)*obj.u_g(s,:);
%             obj.f_0 = model.R_0g*obj.f_g;
%             
%             % recover and store selected response data at nodes and elements 
%             obj = model.point.recover(obj,caseControl,model);
%             obj = model.element.recover(obj,caseControl);
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

