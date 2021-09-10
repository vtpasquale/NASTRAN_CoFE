% Class for output requests
% Anthony Ricciardi
classdef OutputRequest
    
    properties
        n = int32(0) % [int32] Number used to indicate output request. Options: 
                     %   -1 -> Response at all relevant points will be output
                     %    0 -> No response will be output
                     %    n -> Response points in OutputSet.ID = n will be output
        
        print = true; % [logical] Set by the input file processor, but 
                      % currently unused. Designed to specify the output 
                      % medium. Print output is difficult to maintain, so
                      % it is currently unsupported. All requested output
                      % is stored in the solution object and optionally
                      % written to binary output, depending on MDLPRM.
                      % 
                      % Optional future usage:
                      %  true -> Requested output will be printed to a human-readable text output file
                      % false -> Requested output will be printed to a binary file
    end
    methods
        function obj = set.n(obj,in)
            if isempty(in)
                % empty OutputRequest.n is OK initially
            else
                if ~isnumeric(in); error('OutputRequest.n must be numeric.'); end
                if mod(in,1) ~= 0; error('OutputRequest.n must be an integer.'); end
                if in < -1; error('OutputRequest.n must be greater than or equal to -1.'); end
            end
            obj.n = int32(in);
        end
        function rind = getRequestMemberIndices(obj,IDs,outputSet)
            % Returns a vector of of indices of input vector IDs(n,1 int)
            % that correspond to members of the output set. This is useful
            % for the model data recovery process.
            [nobj,mobj] = size(obj);
            if nobj ~= 1 || mobj ~=1
                error('Method get_member_ID_indices does not support arrays of OutputRequest objects. Method get_member_ID_indices is used only for scalar OutputRequest objects. ');
            end
            
            if obj.n == 0 % = NONE
                % Finished if Request = NONE
                rind = uint32([]);
            else
                [nids,mids]=size(IDs);
                if nids < 1; error('Metehod input IDs should have size(IDs,1)>0'); end
                if mids ~= 1; error('Metehod input IDs should have size(IDs,2)=1'); end
                
                if obj.n == -1 % == ALL
                    % Finished if Request = ALL
                    rind = (uint32(1):uint32(nids)).';
                elseif isempty(obj.n)
                    error('The output request is undefined.');
                elseif isempty(outputSet)
                    error('Input argument outputSet cannot be empty.')
                else
                    mos=size(outputSet,2);
                    if mos~=1; error('Array instances of Class outputSet should have size(outputSet,2)==1.'); end
                    if isa(outputSet,'OutputSet')==0; error('outputSet must be an instance of Class OutputSet'); end
                    outputSetIDs = [outputSet.ID].';
                    outputSetID  = find(obj.n==outputSetIDs);
                    if isempty(outputSetID)
                        error('Output Set ID = %d does not exist.',obj.n);
                    else
                        % Get vector indicies from referenced output set 
                        rind = outputSet(outputSetID).getSetMemberIndices(IDs);
                    end
                end
            end
        end
        
    end
end
