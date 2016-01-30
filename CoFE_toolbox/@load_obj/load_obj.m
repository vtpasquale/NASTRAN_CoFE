% Class for LOAD entries.
% Anthony Ricciardi
%
classdef load_obj < entry % Does not conform to applied_load superclass
    
    %% input data
    properties
        SID
        S
        Si
        Li
    end
    
    methods
        
        %%
        function obj = initialize(obj,data)
            obj.SID = set_data('LOAD','SID',data{2},'int',[],1);
            obj.S = set_data('LOAD','S',data{3},'dec',[]);
            
            % create array of scale factors and set ID numbers
            obj.Si(1,1) = set_data('LOAD','Si',data{4},'dec',[]);
            obj.Li(1,1) = set_data('LOAD','Li',data{5},'int',[],1);
            
            i = 1;
            cn = 6;
            for j =6:2:size(data,2)
                if cn == 10
                    cn = 0;
                elseif cn == 1
                    error('There is an issue with your LOAD entry. Bad logic outcome.  ')
                else
                    if isempty(data{j})
                        break
                    end
                    i = i+1;
                    obj.Si(1,i) = set_data('LOAD','Si',data{j},'dec',[]);
                    obj.Li(1,i) = set_data('LOAD','Li',data{j+1},'int',[],1);
                end
                cn = cn + 2;
            end 
            
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'LOAD,%d,%f,%f,%d',obj.SID,obj.S,obj.Si(1,1),obj.Li(1,1));
            if size(obj.Li,2) < 2
                fprintf(fid,'\n');
            else
                fn = 6;
                for i = 2:size(obj.Li,2)
                    fn = fn+2;
                    fprintf(fid,',%f,%d',obj.Si(1,i),obj.Li(1,i));
                    if fn == 10
                        fprintf(fid,'\n,');
                        fn = 2;
                    end
                end
                fprintf(fid,'\n,');
            end
        end
        
    end
end
