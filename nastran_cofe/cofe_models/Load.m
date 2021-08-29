% Abstract superclass for loads
% Anthony Ricciardi
%
classdef (Abstract) Load < matlab.mixin.Heterogeneous

    properties (Abstract)
        sid % [int] Load set identification number.
    end
    methods (Abstract)
        assemble_sub(obj,model)
    end
    methods (Sealed=true)
%         function obj = preprocess(obj,model)
%             % preprocess loads
%             [nloads,m] = size(obj);
%             if m > 1; error('loads.preprocess() can only handel nx1 arrays of loads objects. The second dimension exceeds 1.'); end
%             
%             % Loop through loads
%             for i=1:nloads
%                 obj(i)=obj(i).preprocess_sub(model);
%             end
%         end
        function model = assemble(obj,model)
            nLoads = size(obj,1);
            nCases = size(model.loadSIDs,1);
            p_g = zeros(model.nGdof,nCases);
            isLoadCombination = arrayfun(@(x)isa(x,'LoadCombination'),obj);
            
            
            % Loop through loads and apply. Skip load combinations.
            for i=1:nLoads
                if ~isLoadCombination(i)
                    oi=obj(i);
                    lc = find(oi.sid==model.loadSIDs);
                    [pe_g,gdof]=oi.assemble_sub(model);
                    p_g(gdof,lc)=p_g(gdof,lc)+pe_g;
                end
            end
            
            % Apply load combinations
            if any(isLoadCombination)
                loadCombinations = find(isLoadCombination);
                loadCombinationsSid = [obj(loadCombinations).sid].';
                if size(unique(loadCombinationsSid),1)~=size(loadCombinationsSid,1)
                    error('LOAD entry SID fields must be unique.')
                end
                notLoadCombinationsSid = [obj(~isLoadCombination).sid];
                
                % loop over load combinations
                for i = 1:size(loadCombinations,1)
                    oi=obj(loadCombinations(i));
                    if any(oi.sid==notLoadCombinationsSid)
                        error('LOAD entry SID fields must be unique with respect to all other input loads (e.g., FORCE, MOMENT, PLOAD4, LOAD).')
                    end
                    lc = find(oi.sid==model.loadSIDs);
                    
                    % loop over referenced loads
                    for j = 1:size(oi.si,2)
                        lj = find(oi.li(j)==model.loadSIDs);
                        if length(lj)~=1; error('LOAD SID = %d references undefined load SID = %d',oi.sid,oi.li(j)); end
                        p_g(:,lc)=p_g(:,lc)+ oi.si(j)*p_g(:,lj);
                    end
                    % overall scale factor
                    p_g(:,lc)=oi.s*p_g(:,lc);
                end
            end % load combinations
            
            % save to model
            model.p_g=p_g;
        end
    end
    
end

