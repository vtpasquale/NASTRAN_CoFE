% Model class to store input data that defines degree of freedom sets.
% The data are convereted to logical arrays after global degrees of
% freedom are defined.
% Anthony Ricciardi
%
classdef DofSet
    properties
        name % [1,1 char] Name of set (e.g., 'a','b','c', or 'q')
        c % [:,1 uint32] Component numbers between 1 and 6.
        id % [:,1 uint32] point identification numbers.
    end
    methods
        function obj = DofSet(nameIn,cIn,idIn)
            % class constructor
            obj.name = nameIn;
            obj.c = cIn;
            obj.id = idIn;
        end
        % class to define logical sets from this data
    end
end
