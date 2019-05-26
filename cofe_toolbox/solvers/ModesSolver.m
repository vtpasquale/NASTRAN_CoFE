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
            
            
            % process EIGRL input
            nModes = model(1).getNumModes(obj(1).caseControlIndex);
            
            % Residual structure analysis matricies
            K_aa = model(1).reducedModel.K_aa;
            M_aa = model(1).reducedModel.M_aa;
            
            % Check sets
            nAset = size(K_aa,1);
            if nModes>nAset
                nModes=nAset;
                warning('The number of modes requested by the EIGRL input is larger than the analysis set - the number of modes recovered will be less than requested.')
            end
            
            % Solve
            [u_a,D] = eigs(M_aa,K_aa,nModes); % -> (1/w^2) * K * V = M * V is more reliable than K * V = w^2 * M * V
            eigenvalues = diag(D).^-1;
            
            % Sort by eigenvalue (eigs() does not always return sorted eigenvalues and eigenvectors)
            [eigenvalues,index]=sort(eigenvalues);
            u_a = u_a(:,index);
            
            % Mass normalize eigenvectors
            u_a = u_a./repmat(sqrt(diag(u_a.'*M_aa*u_a)).',[nAset,1]);
            
            % Store Eigenvalue table
            obj(1).eigenvalueTable = EigenvalueTable(eigenvalues,diag(u_a.'*M_aa*u_a),diag(u_a.'*K_aa*u_a));
            
            % Recover model results
            obj = model.recover(obj,u_a);
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
                    
                    % temporary hack
                    nModes = size(obj.displacement_g.T1,2);
                    % Write output to FEMAP data blocks
                    for ID = 1:nModes;% [int] ID of output set
                        title = sprintf('Mode %d',ID); % [max 79 char] Output Set title
                        anal_type = 1; % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
                        ProcessType = 0; % [int] Processing option for 'As Needed' Output Sets ( 0=None, 1=Linear Combination, 2=RSS Combination, 3=Max Envelope, 4=Min Envelope, 5=AbsMax Envelope, 6=Max Envelope SetID, 7=Min Envelope SetID, 8=AbsMax Envelope SetID)
                        value = 0.0; % [real] Time or Frequency value for this case. 0.0 for static analysis.
                        notes = 'Notes text. '; % [1xN char] One line of text.
                        StudyID = 1; % [int] ID of Analysis Study
                        nas_case = caseControl.subcase; % [int] Nastran SUBCASE ID associated with these results
                        nas_rev = 0; % [int] Revision of Nastran SUBCASE
                        obj.femapDataBlock=[obj.femapDataBlock;FemapDataBlock450(ID,title,anal_type,ProcessType,value,notes,StudyID,nas_case,nas_rev)];
                    end
                    
                    obj.femapDataBlock = [obj.femapDataBlock;convert_2_FemapDataBlock1051(obj.displacement_0,1)];
                end
            end
        end
        function femapDataBlock = writeFemapOutputSets(obj,femapDataBlock,caseControl,outputHeading)
            
            % Fixed parameters
            anal_type = 2; % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
            ProcessType = 0; % [int] Processing option for 'As Needed' Output Sets ( 0=None, 1=Linear Combination, 2=RSS Combination, 3=Max Envelope, 4=Min Envelope, 5=AbsMax Envelope, 6=Max Envelope SetID, 7=Min Envelope SetID, 8=AbsMax Envelope SetID)
            value = 0.0; % [real] Time or Frequency value for this case. 0.0 for static analysis.
            notes = 'Notes text. '; % [1xN char] One line of text.
            StudyID = femapDataBlock(1).currentAnalysisStudy(); % [int] ID of Analysis Study
            nas_case = caseControl.subcase; % [int] Nastran SUBCASE ID associated with these results
            nas_rev = 0; % [int] Revision of Nastran SUBCASE
            
            nModes = size(outputHeading.headingVector,1);
            for i = 1:nModes
                ID = femapDataBlock(1).currentOutputSet();
                femapDataBlock(1) = femapDataBlock(1).advanceOutputSet();
                title = sprintf('Mode %d, %f Hz',i,outputHeading.headingVector(i)); % [max 79 char] Output Set title
                
                femapDataBlock=[femapDataBlock;...
                    FemapDataBlock450(ID,title,anal_type,ProcessType,value,notes,StudyID,nas_case,nas_rev)
                    ];
            end
            
        end
        
%             %% Output results data
% 
%             % Write output to FEMAP data blocks
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

