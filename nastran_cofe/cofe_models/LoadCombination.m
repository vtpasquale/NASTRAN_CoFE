% Class static load combination.
% Anthony Ricciardi
%
classdef LoadCombination < Load
    
    properties
        sid % [uint32] Load set identification number. ( > 0)
        s % [double] Overall scale factor. 
        si % [n,1 double] Scale factor on li.
        li % [n,1 uint32] Load set identification numbers.
    end
    methods
        function [p_g,gdof]=assemble_sub(obj)
            % This function is unused. Included to satisfy Load superclass requirements.
            gdof = [];
            p_g = [];
        end
    end
end
