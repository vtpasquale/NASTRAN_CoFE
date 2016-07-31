% Class to store case control data
% Anthony Ricciardi
%
classdef case_obj
    
    properties
        TITLE=''; % Defines a character string to appear on the first heading line of each page
        SUBTITLE=''; % Defines a character string to appear on the first heading line of each page
        SOL % (101, 103, or 105) Specifies the type of analysis being performed
        SPC % (int > 0 or blank) Selects a single point constraint set to be applied
        LOAD % (int > 0 or blank) Selects a load set to be applied
        METHOD % (int > 0 or blank) Selects the real eigenvalue extraction parameters
        FORCE = 0; % (0 or 1) Requests element force output
        STRESS=0; % (0 or 1) Requests element stress output
        STRAIN=0; % (0 or 1) Requests element strain output
        ESE=0; % (0 or 1) Requests element strain energy output
        EKE=0; % (0 or 1) Requests element kinetic energy output
        REF_LC % (int > 1 or blank) Subcase index of static reference solution for buckling analysis
    end
    
    properties (Dependent=true)
        RECOVER % returns 1 if element recovery is requested, 0 otherwise.  
    end
    
    methods
        %% Get Methods
        function out = get.RECOVER(obj)
            if any([obj.STRESS,obj.STRAIN,obj.ESE,obj.EKE]==1)% any(strcmp({obj.STRESS,obj.STRAIN,obj.ESE,obj.EKE},'ALL'))
                out = 1;
            else
                out = 0;
            end
        end
        
        %% Set Methods
        function obj = set.TITLE(obj,in)
            if ischar(in)==0; error('CASE.title must be a string'); end
            obj.TITLE=in;
        end
        function obj = set.SUBTITLE(obj,in)
            if ischar(in)==0; error('CASE.subtitle must be a string'); end
            obj.SUBTITLE=in;
        end
        function obj = set.SOL(obj,in)
            if isnumeric(in)==0; error('CASE.SOL must be a number'); end
            if any(size(in)~=[1 1]); error('CASE.SOL must be scalar'); end
            if any(in==[101 103 105])~=1
                error('CASE.SOL should be set to 101, 103, or 105.')
            end
            obj.SOL=in;
        end
        function obj = set.SPC(obj,in)
            obj.SPC=setInt(in,'CASE.SPC');
        end
        function obj = set.LOAD(obj,in)
            obj.LOAD=setInt(in,'CASE.LOAD');
        end
        function obj = set.METHOD(obj,in)
            obj.METHOD=setInt(in,'CASE.METHOD');
        end
        function obj = set.REF_LC(obj,in)
            obj.REF_LC=setInt(in,'CASE.REF_LC');
        end
        
        function obj = set.FORCE(obj,in)
            obj.FORCE=setEleRecover(in,'CASE.FORCE');
        end
        function obj = set.STRESS(obj,in)
            obj.STRESS=setEleRecover(in,'CASE.STRESS');
        end
        function obj = set.STRAIN(obj,in)
            obj.STRAIN=setEleRecover(in,'CASE.STRAIN');
        end
        function obj = set.EKE(obj,in)
            obj.EKE=setEleRecover(in,'CASE.EKE');
        end
        function obj = set.ESE(obj,in)
            obj.ESE=setEleRecover(in,'CASE.ESE');
        end
        
    end
    
end

function out = setInt(in,errStr)
if isnumeric(in)==0; error([errStr,' must be a number']); end
if mod(in,1) ~= 0; error([errStr,' must be an integer']); end
if in < 1; error([errStr,' must be greater than zero.']); end
out=in;
end

function out = setEleRecover(in,errStr)
if in ~= 0 && in ~= 1
    error([errStr,' must be 0 or 1.']);
end
out=in;
end