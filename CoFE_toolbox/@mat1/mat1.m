% Class for MAT1 entries
% Anthony Ricciardi
%
classdef mat1 < entry
    
    % entry data
    properties
        MID
        E
        G
        NU
        RHO
    end
    
    methods
        %%
        function obj = initialize(obj,data)
            obj.MID = set_data('MAT1','MID',data{2},'int',[],1);
            obj.E = set_data('MAT1','E',data{3},'dec',[]);
            obj.G = set_data('MAT1','G',data{4},'dec',-999);
            obj.NU = set_data('MAT1','NU',data{5},'dec',-999);
            obj.RHO = set_data('MAT1','RHO',data{6},'dec',0.0);
        end
        
        %%
        function val = stress_strain_mat(obj)
            
            % check previous inputs
            if sum([obj.E,obj.G,obj.NU]==-999)>1
                error(['Error with MAT1 ',numstr(obj.MID),'. More than one of E, G, or NU is blank.'])
            end
            if obj.G == -999
                obj.G = obj.E/(2*(1+obj.NU));
            elseif obj.NU == -999
                obj.NU = obj.E/(2*obj.G) - 1;
            elseif obj.E == -999
                obj.E = 2*(1+obj.NU)*obj.G;
            end
            
            % isotropic stress strain matrix
            val = obj.E/(1-obj.NU.^2)*[1 obj.NU 0; obj.NU 1 0; 0 0 (1-obj.NU)./2];
        end
        
        %%
        function [E,G,NU] = getEGNU(obj)
            
            % check previous inputs
            if sum([obj.E,obj.G,obj.NU]==-999)>1
                error(['Error with MAT1 ',numstr(obj.MID),'. More than one of E, G, or NU is blank.'])
            end
            if obj.G == -999
                obj.G = obj.E/(2*(1+obj.NU));
            elseif obj.NU == -999
                obj.NU = obj.E/(2*obj.G) - 1;
            elseif obj.E == -999
                obj.E = 2*(1+obj.NU)*obj.G;
            end
            
            % values
            E = obj.E;
            G = obj.G;
            NU = obj.NU;
        end
        
        %%
        function echo(obj,fid)
            [E,G,NU] = getEGNU(obj);
            fprintf(fid,'MAT1,%d,%f,%f,%f,%f\n',obj.MID,E,G,NU,obj.RHO);
        end
    end
end

