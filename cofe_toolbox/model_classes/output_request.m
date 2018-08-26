% Class for output requests
% Anthony Ricciardi
classdef output_request
    
    properties
        none = true % [logical] No response will be output if true
        all  = false % [logical] Response at all relevant points will be output if true
        n % [uint32] Set ID of a defined output_set object. Only response of points that appear on this output_set will be output.
    end
    methods
        function obj = set.none(obj,in)
            if ~islogical(in); error('output_request.none must be a logical (true/false) variable.'); end
            if in == true
                obj.all = false;
            end
            obj.none = in;
        end
        function obj = set.all(obj,in)
            if ~islogical(in); error('output_request.all must be a logical (true/false) variable.'); end
            if in == true
                obj.none = false;
            end
            obj.all = in;
        end
        function obj = set.n(obj,in)
            if isempty(in)
                % empty output_request.n is OK
            else
                if ~isnumeric(in); error('output_request.n must be numeric or empty variable.'); end
                if mod(in,1) ~= 0; error('output_request.n must be an integer or empty variable'); end
                if in < 1; error('output_request.n must be greater than zero.'); end
                obj.none = false;
                obj.all = false;
            end
            obj.n = uint32(in);
        end
        function rind = get_member_ID_indices(obj,IDs,OUTPUT_SETS)
            % Returns a vector of of indices of input vector IDs(n,1 int)
            % that correspond to members of the output set. This is useful
            % for the model data recovery process.
            [nobj,mobj] = size(obj);
            if nobj ~= 1 || mobj ~=1
                error('Method get_member_ID_indices does not support arrays of output_request objects. Method get_member_ID_indices is used only for scalar output_request objects. ');
            end
            
            if obj.none == true
                % Finished if Request = NONE
                rind = uint32([]);
            else
                [nids,mids]=size(IDs);
                if nids < 1; error('Metehod input IDs should have size(IDs,1)>0'); end
                if mids ~= 1; error('Metehod input IDs should have size(IDs,2)=1'); end
                
                if obj.all == true
                    % Finished if Request = ALL
                    rind = uint32(1:nids).';
                elseif isempty(obj.n)
                    error('The output request is undefined.');
                elseif isempty(OUTPUT_SETS)
                    error('Input argument OUPUT_SETS cannot be empty.')
                else
                    [~,mos]=size(OUTPUT_SETS);
                    if mos~=1; error('Array instances of Class output_set should have size(output_set,2)==1.'); end
                    if isa(OUTPUT_SETS,'output_set')==0; error('OUTPUT_SETS must be an instance of Class output_set'); end
                    output_set_IDs = [OUTPUT_SETS.ID].';
                    output_set_ID  = find(obj.n==output_set_IDs);
                    if isempty(output_set_ID)
                        error('Output Set ID = %d does not exist.',obj.n);
                    else
                        % Get vector indicies from referenced output set 
                        rind = OUTPUT_SETS(output_set_ID).get_member_ID_indices(IDs);
                    end
                end
            end
        end
        
    end
end
