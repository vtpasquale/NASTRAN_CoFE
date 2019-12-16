classdef Hdf5ElementForceRod < Hdf5ElementForce
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EID
        AF
        TRQ
        DOMAIN_ID
    end
    properties (Constant = true)
        DATASET = 'ROD';
    end
    methods
        function obj = Hdf5ElementForceRod(filename)
            if nargin < 1
            else
                obj = Hdf5ElementForceRod();
                obj = obj.constructFromFile_sub(filename);
            end
        end
    end   
end

