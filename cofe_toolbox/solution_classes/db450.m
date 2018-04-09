% Class for FEMAP Neutral File Data Block 450 - Output Sets
% Anthony Ricciardi
%
classdef db450 < db
    
    properties
        ID % [int] ID of output set
        title % [max 79 char] Output Set title
        anal_type % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
        ProcessType % [int] Processing option for 'As Needed' Output Sets ( 0=None, 1=Linear Combination, 2=RSS Combination, 3=Max Envelope, 4=Min Envelope, 5=AbsMax Envelope, 6=Max Envelope SetID, 7=Min Envelope SetID, 8=AbsMax Envelope SetID)
        value % [real] Time or Frequency value for this case. 0.0 for static analysis.
        notes % [1xN char] One line of text.
        StudyID % [int] ID of Analysis Study
        nas_case % [int] Nastran SUBCASE ID associated with these results
        nas_rev % [int] Revision of Nastran SUBCASE
    end
    properties (Constant = true, Hidden = true)
        from_prog = 0; % Analysis program where output came from
        IntegerFormat = false; % Logical
        nlines = 1; % Number of lines of text in the following notes
        AttachID = 0; % When output is imported into the FEMAP database, the Attach ID will always be 0 and the Location ID can only be 0 (Auto) or 1 (Database).
        LocationID = 0;% See AttachID
    end
    methods
        function writeNeu(obj,fid)
            % Writes single data block to FEMAP Neutral File
            fprintf(fid,'   -1\n');
            fprintf(fid,'   450\n');
            fprintf(fid,'%d\n',obj.ID);
            fprintf(fid,'%s\n',obj.title);
            fprintf(fid,'%d,%d,%d,%d\n',obj.from_prog,obj.anal_type,obj.ProcessType,obj.IntegerFormat);
            fprintf(fid,'%G\n',obj.value);
            fprintf(fid,'%d\n',obj.nlines);
            fprintf(fid,'%s\n',obj.notes);
            fprintf(fid,'%d,%d,%d\n',obj.AttachID,obj.LocationID,obj.StudyID);
            fprintf(fid,'-1,-1,0\n');
            fprintf(fid,'%d,%d\n',obj.nas_case,obj.nas_rev);
             fprintf(fid,'   -1\n');
        end
        function obj = db450(ID,title,anal_type,ProcessType,value,notes,StudyID,nas_case,nas_rev)
            % db450 class constructor method
            if nargin ~= 0
                obj.ID=ID; % [int] ID of output set
                obj.title=title; % [max 79 char] Output Set title
                obj.anal_type=anal_type; % [int] Type of analysis (0=Unknown, 1=Static, 2=Modes, 3=Transient, 4=Frequency Response, 5=Response Spectrum, 6=Random, 7=Linear Buckling, 8=Design Opt, 9=Explicit, 10=Nonlinear Static, 11=Nonlinear Buckling, 12=Nonlinear Transient, 19=Comp Fluid Dynamics, 20=Steady State Heat Transfer, 21=Transient Heat), 22=Advanced Nonlinear Static, 23=Advanced Nonlinear Transient, 24=Advanced Nonlinear Explicit, 25=Static Aeroelasticity, 26=Aerodynamic Flutter)
                obj.ProcessType=ProcessType; % [int] Processing option for 'As Needed' Output Sets ( 0=None, 1=Linear Combination, 2=RSS Combination, 3=Max Envelope, 4=Min Envelope, 5=AbsMax Envelope, 6=Max Envelope SetID, 7=Min Envelope SetID, 8=AbsMax Envelope SetID)
                obj.value=value; % [real] Time or Frequency value for this case. 0.0 for static analysis.
                obj.notes=notes; % [1xN char] One line of text.
                obj.StudyID=StudyID; % [int] ID of Analysis Study
                obj.nas_case=nas_case; % [int] Nastran SUBCASE ID associated with these results
                obj.nas_rev=nas_rev; % [int] Revision of Nastran SUBCASE
            end
        end
    end
end

