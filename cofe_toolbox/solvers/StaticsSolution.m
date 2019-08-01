% Class that defines a static analysis.
% Anthony Ricciardi
%
classdef StaticsSolution < Solution
    
    properties
        u_g
        u_0
        f_g
        f_0
        
        displacement_0
        displacement_g
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
            
            model0 = model(1); % Residual structure
            caseControl0 = model0.caseControl(obj.caseControlIndex);
            
            obj.u_g=zeros(model0.nGdof,1);
            obj.u_0=zeros(model0.nGdof,1);
                        
            if isempty(caseControl0.load); error('No load case identification number specified.'); end
            lc = find(caseControl0.load==model0.loadSIDs);
            if isempty(lc); warning('No applied loads found for this case.'); end
            
            % sets
            f=model0.f;
            s=model0.s;
            
            %% Solve
            
            % displacements
            obj.u_g(f) = model0.K_gg(f,f)\model0.p_g(f,lc);
            obj.u_0    = model0.R_0g*obj.u_g;
            
            % constraint forces
            obj.f_g = zeros(size(obj.u_g));
            obj.f_g(s) = model0.K_gg(s,f)*obj.u_g(f) + model0.K_gg(s,s)*obj.u_g(s);
            obj.f_0 = model0.R_0g*obj.f_g;
            
            % recover and store selected response data at nodes and elements 
            obj = model.point.recover(obj,model);
            obj = model.element.recover(obj,model);
        end
        function femapDataBlock = constructFemapAnalysisSet(obj,femapDataBlock,caseControl)
            ID = femapDataBlock(1).currentAnalysisStudy; % [int] ID of Study
            if isempty(caseControl.title)
                Title =  sprintf('CoFE Analysis Study %d',ID);% [1xN char] Title of Analysis Study
            else
                Title = caseControl.title;
            end
            Analysis_Type = 1; % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
            Analysis_Set = ID; % [int] ID of Femap Analysis Set used for solution
            Study_Notes = 'Study Notes';% [1xN char] text
             femapDataBlock=[femapDataBlock;...
                 FemapDataBlock1056(ID,Title,Analysis_Type,Analysis_Set,Study_Notes)];
        end
        function femapDataBlock = constructFemapOutputSets(obj,femapDataBlock,caseControl,outputHeading)
            anal_type = 1; % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
            ProcessType = 0; % [int] Processing option for 'As Needed' Output Sets ( 0=None, 1=Linear Combination, 2=RSS Combination, 3=Max Envelope, 4=Min Envelope, 5=AbsMax Envelope, 6=Max Envelope SetID, 7=Min Envelope SetID, 8=AbsMax Envelope SetID)
            value = 0.0; % [real] Time or Frequency value for this case. 0.0 for static analysis.
            notes = 'Notes text. '; % [1xN char] One line of text.
            StudyID = femapDataBlock(1).currentAnalysisStudy; % [int] ID of Analysis Study
            nas_case = caseControl.subcase; % [int] Nastran SUBCASE ID associated with these results
            nas_rev = 0; % [int] Revision of Nastran SUBCASE
            
            ID = femapDataBlock(1).currentOutputSet();
            femapDataBlock(1) = femapDataBlock(1).advanceOutputSet();
            title = sprintf('Statics Subcase %d',caseControl.subcase); % [max 79 char] Output Set title
            
            femapDataBlock=[femapDataBlock;...
                FemapDataBlock450(ID,title,anal_type,ProcessType,value,notes,StudyID,nas_case,nas_rev)
                ];
        end

%         function obj = output_sub(obj,caseControl,writeFemapFlag,fid)
%             
%             % Output select results
%             if caseControl.displacement.n~=0
%                 if caseControl.displacement.print==true
%                     obj.displacement_g.echo(fid) % To text output file
%                 end
%                 if writeFemapFlag
%                     obj.femapDataBlock = [obj.femapDataBlock;convert_2_FemapDataBlock1051(obj.displacement_0,1)];
%                 end
%             end
%         end
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
%             % Write FEMAP data blocks to file
%             fid = 1;
%             obj.femapDataBlock.writeNeutral(fid) ;
%             fclose('all');
    end
end

