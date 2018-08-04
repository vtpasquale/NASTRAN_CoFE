% Class for output sets
% Anthony Ricciardi
classdef output_set
    
    properties
        ID % [int] Set identification number
        all % [logical] indicates all entities should be output
        i1 % [n,1 uint32] list of individual identification numbers and the first identification number for any THRU ranges
        iN % [n,1 uint32] list of the second identification number for any THRU ranges
        thru % [n,1 logical] true where i1(thru,1) and iN(thru,1) contain THRU ranges
    end
    properties (Dependent = true, Hidden = true)
        values % [nset:1 uint32] sorted vector of all unique integers in output set
    end
    
    methods
        function val = get.values(obj)
            [nn,mm] = size(obj);
            if nn ~= 1 || mm ~=1
                error('Method get.values does not support arrays of output_set objects. Method get.values is used only for scalar output_set objects. ');
            end
            if obj.all == true
                error('You should not be getting the property "values" for output_sets with property "all" = true.')
            else
                if any(obj.thru) == false
                    val = obj.i1;
                else
                    n = size(obj.i1,1);
                    
                    % ensure obj.iN = 0 without THRU
                    obj.iN(~obj.thru)=0;
                    
                    % create dummy variable
                    dummy = zeros(2*n,1);
                    dummy(1:2:end) = obj.i1;
                    dummy(2:2:end) = obj.iN;
                    
                    % create eval string
                    eval_str = ['val = uint32([',...
                        sprintf('%d:%d,',dummy(1:end-2)),...
                        sprintf('%d:%d',dummy(end-1:end)),...
                        ']).'';'];
                    
                    % correct eval string
                    eval_str = strrep(eval_str,':0','');
                    
                    % evaluate
                    eval(eval_str);
                    
                    % return sorted and unique values
                    val = unique(val);
                end
            end
        end
        function rind = get_member_ID_indices(obj,IDs)
            % Returns a vector of of indices of input vector IDs(n,1 int)
            % that correspond to members of the output set. This is useful 
            % for the model data recovery process.
            [nn,mm] = size(obj);
            if nn ~= 1 || mm ~=1
                error('Method get_member_ID_indices does not support arrays of output_set objects. Method get_member_ID_indices is used only for scalar output_set objects. ');
            end
            
            [n,m]=size(IDs);
            if n < 1; error('Metehod input IDs should have size(IDs,1)>0'); end
            if m ~= 1; error('Metehod input IDs should have size(IDs,2)=1'); end
            
            if obj.all == true
                rind = (1:n).';
            else
                rind = find(ismember(IDs,obj.values));
            end
        end
        function echo(obj,fid)
            % Print the entries in NASTRAN free field format to a text file with file ID fid
            if nargin < 2; error('Input argument missing.'); end
            [n,m] = size(obj);
            if m > 1; error('output_set.echo() can only handel nx1 arrays of output_set objects. The second dimension exceeds 1.'); end
            for i = 1:n
                echo_sub(obj(i),fid)
            end
        end
        function disp(obj)
            [n,m] = size(obj);
            if m > 1; error('output_set.disp() can only handel nx1 arrays of output_set objects. The second dimension exceeds 1.'); end
            
            if n > 1
                fprintf(1,'%dx1 output_set with echo:\n\n',n);
            else
                fprintf(1,'output_set with echo:\n\n');
            end
            echo(obj,1);
        end
    end
    methods (Access=private)
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            if isempty(obj.ID); error('Cannot echo a set without an ID number'); end
            if obj.all == true
                fprintf(fid,'SET %d = ALL\n',obj.ID)
            else
                if any(obj.thru) == false
                    longstr = [sprintf('SET %d = ',obj.ID),...
                        sprintf('%d,',obj.i1(1:end-1)),...
                        sprintf('%d',obj.i1(end))];
                else
                    n = size(obj.i1,1);
                    
                    % ensure obj.iN = 0 without THRU
                    obj.iN(~obj.thru)=0;
                    
                    % create dummy variable
                    dummy = zeros(2*n,1);
                    dummy(1:2:end) = obj.i1;
                    dummy(2:2:end) = obj.iN;
                    
                    % create dummy string
                    dummy_str = [sprintf('SET %d = ',obj.ID),...
                        sprintf('%d THRU %d,',dummy(1:end-2)),...
                        sprintf('%d THRU %d',dummy(end-1:end))];
                    
                    % correct dummy string
                    longstr = strrep(dummy_str,' THRU 0','');
                end
                % For long sets, insert break lines after certain commas
                if size(longstr,2)>73
                    commas = strfind(longstr,',');
                    commas_dummy = commas;
                    ind = 1;
                    while 1
                        find73 = find(commas_dummy > 73);
                        if isempty(find73)
                            break
                        end
                        repIND(ind) = find73(1)-1;
                        commas_dummy(repIND(ind)+1:end) = commas_dummy(repIND(ind)+1:end)-commas_dummy(repIND(ind));
                        ind = ind + 1;
                    end
                    longstr(commas(repIND))='*';
                    longstr=strrep(longstr,'*',',\n');
                end
                fprintf(fid,[longstr,'\n']);
            end
        end
    end
end
