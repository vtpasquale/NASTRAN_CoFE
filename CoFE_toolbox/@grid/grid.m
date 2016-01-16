% Class for GRID entries
% Anthony Ricciardi
%
classdef grid < entry
    
    % entry data
    properties
        ID
        CP
        X1
        X2
        X3
        CD
        PS
        SEID
    end
        methods
            
            %%
            function obj = initialize(obj,data)                
                obj.ID = set_data('GRID','ID',data{2},'int',[],1,100000000);
                obj.CP = set_data('GRID','CP',data{3},'int',0 ,0);
                % if obj.CP ~= 0; error('Nonzero GRID CP not supported.'); end
                obj.X1 = set_data('GRID','X1',data{4},'dec',[]);
                obj.X2 = set_data('GRID','X2',data{5},'dec',[]);
                obj.X3 = set_data('GRID','X3',data{6},'dec',[]);
                obj.CD = set_data('GRID','CD',data{7},'int',0);
                if obj.CD ~= 0; error('Nonzero GRID CD not supported.'); end
                obj.PS = set_data('GRID','PS',data{8},'int',-999); % set to -999 if blank
                obj.SEID = set_data('GRID','SEID',data{9},'int',0);
                if obj.SEID ~= 0; error('Nonzero GRID SEID not supported.'); end
            end
            
            %%
            function plot(obj)
                plot3(obj.X1,obj.X2,obj.X3,'k.','markers',15)
            end
            
            %%
            function echo(obj,fid)
                if obj.PS == -999
                    fprintf(fid,'GRID,%d,%d,%f,%f,%f,%d\n',obj.ID,obj.CP,obj.X1,obj.X2,obj.X3,obj.CD);
                else
                    fprintf(fid,'GRID,%d,%d,%f,%f,%f,%d,%d\n',obj.ID,obj.CP,obj.X1,obj.X2,obj.X3,obj.CD,obj.PS);
                end
            end
            
        end
end

