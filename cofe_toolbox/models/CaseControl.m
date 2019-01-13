% Class for case control
% Anthony Ricciardi
%
classdef CaseControl
    
    properties
        ID = uint32(1); % [uint32] Subcase identification number.
        analysis; % [char] Specifies the type of analysis being performed for the current subcase

        % Titles
        title=''; % [char] Defines a title to appear on the first heading line of each page
        subtitle=''; % [char] Defines a subtitle to appear on the second heading line of each page
        label=''; % [char] Defines a label to appear on the third heading line of each page
        
        % Analysis selections
        spc % (int > 0 or blank) Selects a single point constraint set to be applied
        load % (int > 0 or blank) Selects a load set to be applied
        method % (int > 0 or blank) Selects the real eigenvalue extraction parameters
        
        % Output sets
        outputSet@OutputSet; % [nsets,1] Array of OutputSet objects
        
        % Nodal response output requests
        displacement = OutputRequest(); % [OutputRequest] Requests the form and type of nodal displacement output
        velocity     = OutputRequest(); % [OutputRequest] Requests the form and type of nodal velocity output
        acceleration = OutputRequest(); % [OutputRequest] Requests the form and type of nodal acceleration output
        spcforces    = OutputRequest(); % [OutputRequest] Requests the form and type of single-point force of constraint vector output
        
        % Element response output requests
        force  = OutputRequest(); % [OutputRequest] Requests the form and type of element force output
        stress = OutputRequest(); % [OutputRequest] Requests the form and type of element stress output
        strain = OutputRequest(); % [OutputRequest] Requests the form and type of element strain output
        ese    = OutputRequest(); % [OutputRequest] Requests the form and type of element strain energy output
        eke    = OutputRequest(); % [OutputRequest] Requests the form and type of element kinetic energy output
    end
    
    methods
       
        %% Set Methods
        function obj = set.analysis(obj,in)
            if ischar(in)==0; error('CaseControl.ANALYSIS must be a string'); end
            opts = {'STATICS','MODES','BUCK'};
            switch in
                case opts
                otherwise
                    error('Case control ''ANALYSIS = %s'' not supported.',in)
            end
            obj.analysis=in;
        end
        function obj = set.title(obj,in)
            if ischar(in)==0; error('CaseControl.title must be type char'); end
            obj.title=in;
        end
        function obj = set.subtitle(obj,in)
            if ischar(in)==0; error('CaseControl.subtitle must be type char'); end
            obj.subtitle=in;
        end
        function obj = set.label(obj,in)
            if ischar(in)==0; error('CaseControl.LABEL must be type char'); end
            obj.label=in;
        end
        function obj = set.outputSet(obj,in)
            if isa(in,'OutputSet')==0; error('CaseControl.outputSet must be an instanct of Class OutputSet'); end
            [~,m]=size(in);
            if m~=1; error('Array instances of Class output_set should have size(outputSet,2)==1.'); end
            obj.outputSet=in;
        end
        function obj = set.spc(obj,in)
            obj.spc=setInt(in,'CaseControl.spc');
        end
        function obj = set.load(obj,in)
            obj.load=setInt(in,'CaseControl.load');
        end
        function obj = set.method(obj,in)
            obj.method=setInt(in,'CaseControl.method');
        end  
        
        %% 
        function output(obj,fid)
            % Function to write subcase header
            fprintf(fid,'\n\n\n');
            fprintf(fid,[repmat('=',[1 104]),'\n']);
            fprintf(fid,[repmat(' ',[1 floor((104-17)/2)]),'S U B C A S E  %d\n'],obj.ID);
            fprintf(fid,[repmat(' ',[1 floor((104-size(obj.analysis,2))/2)]),'%s\n'],obj.analysis);
            fprintf(fid,[repmat('=',[1 104]),'\n']);
            fprintf(fid,'  %s\n',obj.title);
            fprintf(fid,'  %s\n',obj.subtitle);
            fprintf(fid,'  %s\n',obj.label);
        end
    end
    
end

function out = setInt(in,errStr)
if isnumeric(in)==0; error([errStr,' must be a number']); end
if mod(in,1) ~= 0; error([errStr,' must be an integer']); end
if in < 1; error([errStr,' must be greater than zero.']); end
out=uint32(in);
end