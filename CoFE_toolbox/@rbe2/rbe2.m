% Class for RBE2 entries.
% Defines a rigid body with independent degrees-of-freedom that are
% specified at a single grid point and with dependent degrees-of-
% freedom that are specified at an arbitrary number of grid points.
%
% Anthony Ricciardi
%
classdef rbe2 < mpc
    
    %% input data
    properties
        EID
        GN
        CM
        GMi
    end
    
    %% model
    properties (Access = public)
        % element universal
        RnRm   % [#CM x #element m] element constraint matrix in global reference frame
        gdofn  % [#CMx1] global index numbers of element n dof
        gdofm  % [#CM * #element m x 1] global index numbers of element m dof
    end
    properties (Access = private)
        xn    % [3 x 1] independant node position
        xm    % [3 x #m nodes] dependant node positions 
        gdofn_plot % [3 x 1] global index of node with independant dof
        gdofm_plot % [3 x #m nodes] global index of nodes with dependant dof
    end
    
    methods
        
        %%
        function obj = initialize(obj,data)
            obj.EID = set_data('RBE2','EID',data{2},'int',[],1,100000000);
            obj.GN = set_data('RBE2','GN',data{3},'int',[],1);
            obj.CM = set_data('RBE2','CM',data{4},'int',[]);
            
            % create array of node numbers for dependent degress of freedom
            % first is required 
            obj.GMi(1,1) = set_data('RBE2','GMi',data{5},'int',[]);
            
            i = 1;
            cn = 6;
            for j =6:size(data,2)
                if cn == 10
                    cn = 0;
                elseif cn == 1
                else
                    if isempty(data{j})
                        break
                    end
                    i = i+1;
                    obj.GMi(1,i) = set_data('RBE2','GMi',data{j},'int',[]);
                end
                cn = cn + 1;
            end 
            
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'RBE2,%d,%d,%d,%d',obj.EID,obj.GN,obj.CM,obj.GMi(1,1));
            if size(obj.GMi,1) < 2
                fprintf(fid,'\n');
            else
                fn = 5;
                for i = 2:size(obj.GMi,1)
                    fn = fn+1;
                    fprintf(fid,'%d',obj.GMi(i,1));
                    if fn == 9
                        fprintf(fid,'\n,');
                        fn = 1;
                    end
                end
            end
        end
        
    end
end
