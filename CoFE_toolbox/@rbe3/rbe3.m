% Class for RBE3 entries.  
% Defines a rigid body with independent degrees-of-freedom that are
% specified at a single grid point and with dependent degrees-of-
% freedom that are specified at an arbitrary number of grid points.
%
% Anthony Ricciardi
%
classdef rbe3 < constraint
    
    %% input data
    properties
        EID
        REFGRID
        REFC
        WT1
        C1
        G1i
    end
    
    %% model
    properties (Access = public)
        RnRm   % [#CM x #element m] element constraint matrix in global reference frame
        gdofn  % [#CMx1] global index numbers of element n dof
        gdofm  % [#CM * #element m x 1] global index numbers of element m dof
    end
    properties (Access = private)
        xn    % [3 x #n nodes] independant node positions
        xm    % [3 x 1] dependant node position
        gdofn_plot % [3 x #n nodes] global index of nodes with independant dof
        gdofm_plot % [3 x 1] global index of node with dependant dof
    end

    methods
%%
        function obj = initialize(obj,data)
            obj.EID = set_data('RBE3','EID',data{2},'int',[],1,100000000);
            obj.REFGRID = set_data('RBE3','REFGRID',data{4},'int',[]);
            obj.REFC = set_data('RBE3','REFC',data{5},'int',[]);
            obj.WT1 = set_data('RBE3','WT1',data{6},'dec',[]);
            obj.C1 = set_data('RBE3','C1',data{7},'int',[]);
                       
            % create array of node numbers for independent degress of freedom
            % first is required 
            obj.G1i(1,1) = set_data('RBE3','G1i',data{8},'int',[]);
            
            i = 1;
            cn = 9;
            for j =9:size(data,2)
                if cn == 10
                    cn = 0;
                elseif cn == 1
                else
                    if isempty(data{j})
                        break
                    end
                    i = i+1;
                    obj.G1i(1,i) = set_data('RBE3','G1i',data{j},'int',[]);
                end
                cn = cn + 1;
            end

        end
        
%%
        function echo(obj,fid)
            fprintf(fid,'RBE3,%d,,%d,%d,%f,%d,%d,',obj.EID,obj.REFGRID,obj.REFC,obj.WT1,obj.C1,obj.G1i(1,1));
            if size(obj.G1i,2) < 2
                fprintf(fid,'\n');
            else
                fn = 8;
                for i = 2:size(obj.G1i,2)
                    fn = fn+1;
                    fprintf(fid,'%d,',obj.G1i(1,i));
                    if i == size(obj.G1i,2)
                        fprintf(fid,'\n');
                    elseif fn == 9 
                        fprintf(fid,'\n,');
                        fn = 1;
                    end
                end
            end
        end
        
    end
end
