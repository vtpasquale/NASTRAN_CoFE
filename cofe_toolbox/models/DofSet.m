% Class to store input data that defines degree of freedom sets
% Anthony Ricciardi
%
classdef DofSet
    properties
        name % [1,1 char] Name of set (e.g., 'a','b','c', or 'q')
        c % [1,: uint32] Component numbers between 1 and 6.
        id % [1,: uint32] point identification numbers.
    end
    methods
        % class constructor
        % class to define logical sets from this data
end
