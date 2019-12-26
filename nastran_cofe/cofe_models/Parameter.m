% Class for model parameters
% Anthony Ricciardi
%
classdef Parameter
    
    properties
        n % [char] Parameter name
        v1 % [char] Parameter value 1
        v2 % [char] Parameter value 1 
    end
    methods
        function model = preprocess(obj,model)          
            nParameter = size(obj,1);
            
            % check that parameters names unique
            parameterNames = upper({obj.n}');
            [~,ia] = unique(parameterNames,'stable');
            if size(ia,1)~=nParameter
                nonunique=setxor(ia,1:nParameter);
                error('Parameter (PARAM) inputs should be unique. Nonunique parameters(s): %s',sprintf('%s,',parameterNames{nonunique}))
            end
            
            % Determine if coupled mass formulation will be used
            coupmass = obj.getParameter('COUPMASS');
            if isempty(coupmass)
                model.coupledMassFlag = false;
            else
                coupmassDouble = castInputField('PARAM','COUPMASS',coupmass,'double',NaN); % use double because signed integers are unsupported in caseInputField()
                if coupmassDouble>0
                    model.coupledMassFlag = true;
                else
                    model.coupledMassFlag = false;
                end
            end
        end % preprocess() 
        function [value1,value2] = getParameter(obj,name)
            index = strcmpi({obj.n}',name);
            if any(index)
                value1 = obj(index).v1;
                value2 = obj(index).v2;
            else
                value1 = [];
                value2 = [];
            end
        end
    end

end
