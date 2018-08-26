% Class for case control
% Anthony Ricciardi
%
classdef case_control
    
    properties
        ANALYSIS; % [char] Specifies the type of analysis being performed for the current subcase

        TITLE=''; % [char] Defines a title to appear on the first heading line of each page
        SUBTITLE=''; % [char] Defines a subtitle to appear on the second heading line of each page
        LABEL=''; % [char] Defines a label to appear on the third heading line of each page
        
        SPC % (int > 0 or blank) Selects a single point constraint set to be applied
        LOAD % (int > 0 or blank) Selects a load set to be applied
        METHOD % (int > 0 or blank) Selects the real eigenvalue extraction parameters
        
        OUTPUT_SETS@output_set; % [nsets,1] Array of output_set objects
        
        DISPLACEMENT = output_request(); % [output_request] Requests the form and type of nodal displacement output
        VELOCITY     = output_request(); % [output_request] Requests the form and type of nodal velocity output
        ACCELERATION = output_request(); % [output_request] Requests the form and type of nodal acceleration output
        
        FORCE  = output_request(); % [output_request] Requests the form and type of element force output
        STRESS = output_request(); % [output_request] Requests the form and type of element stress output
        STRAIN = output_request(); % [output_request] Requests the form and type of element strain output
        ESE    = output_request(); % [output_request] Requests the form and type of element strain energy output
        EKE    = output_request(); % [output_request] Requests the form and type of element kinetic energy output
    end
    
    methods
       
        %% Set Methods
        function obj = set.ANALYSIS(obj,in)
            if ischar(in)==0; error('case_control.ANALYSIS must be a string'); end
            opts = {'STATICS','MODES','BUCK'};
            switch in
                case opts
                otherwise
                    error('Case control ''ANALYSIS = %s'' not supported.',in)
            end
            obj.ANALYSIS=in;
        end
        function obj = set.TITLE(obj,in)
            if ischar(in)==0; error('case_control.title must be a string'); end
            obj.TITLE=in;
        end
        function obj = set.SUBTITLE(obj,in)
            if ischar(in)==0; error('case_control.subtitle must be a string'); end
            obj.SUBTITLE=in;
        end
        function obj = set.LABEL(obj,in)
            if ischar(in)==0; error('case_control.LABEL must be a string'); end
            obj.LABEL=in;
        end
        function obj = set.OUTPUT_SETS(obj,in)
            if isa(in,'output_set')==0; error('case_control.OUTPUT_SETS must be an instanct of Class output_set'); end
            [~,m]=size(in);
            if m~=1; error('Array instances of Class output_set should have size(output_set,2)==1.'); end
            obj.OUTPUT_SETS=in;
        end
        function obj = set.SPC(obj,in)
            obj.SPC=setInt(in,'case_control.SPC');
        end
        function obj = set.LOAD(obj,in)
            obj.LOAD=setInt(in,'case_control.LOAD');
        end
        function obj = set.METHOD(obj,in)
            obj.METHOD=setInt(in,'case_control.METHOD');
        end        
    end
    
end

function out = setInt(in,errStr)
if isnumeric(in)==0; error([errStr,' must be a number']); end
if mod(in,1) ~= 0; error([errStr,' must be an integer']); end
if in < 1; error([errStr,' must be greater than zero.']); end
out=uint32(in);
end