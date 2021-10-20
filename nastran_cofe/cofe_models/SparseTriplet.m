classdef SparseTriplet < handle
    %Class for assembling sparse matrices as triplets
    
    % Anthony Ricciardi
    % 10/2021
    
    properties
        paddedLength % [uint32] Length of the triplet vectors including padding
        nTriplets % [uint32] Number of triplets
        i % [paddedLength, 1 uint32] row indices
        j % [paddedLength, 1 uint32] column indices
        s % [paddedLength, 1 double] matrix values
    end
    
    methods
        function obj = SparseTriplet(paddedLengthIn)
            obj.paddedLength = paddedLengthIn;
            obj.i = zeros(paddedLengthIn,1,'uint32');
            obj.j = obj.i;
            obj.s = zeros(paddedLengthIn,1,'double');
            obj.nTriplets = uint32(0);
        end
        function obj = padVectors(obj)
            % Doubles the size of triplet vectors by padding with zeros
            obj.paddedLength = 2*obj.paddedLength;
            obj.i(obj.paddedLength,1) = uint32(0);
            obj.j(obj.paddedLength,1) = uint32(0);
            obj.s(obj.paddedLength,1) = 0;
        end
        function obj = addMatrix(obj,M,gDof)
            % Adds matrix M with global DOF gDof to SparseTriplet
            [iM,jM,m]=find(M);
            
            % Number management
            lengthM = size(m,1);
            nTripletsOld = obj.nTriplets;
            nTripletsNew = nTripletsOld + lengthM;
            obj.nTriplets = nTripletsNew;
            while nTripletsNew > obj.paddedLength
                obj = padVectors(obj);
            end
            
            % Add values to triplets
            index = nTripletsOld+1:nTripletsNew;
            obj.i(index) = gDof(iM);
            obj.j(index) = gDof(jM);
            obj.s(index) = m;
        end
        function sparseMatrix = convertToSparseMatrix(obj,n,m)
            % convert triplets to sparse matrix
            sparseMatrix = sparse(double( obj.i(1:obj.nTriplets)),...
                                  double( obj.j(1:obj.nTriplets)),...
                                  obj.s(1:obj.nTriplets),...
                                  n,m);
        end
    end
    
end

