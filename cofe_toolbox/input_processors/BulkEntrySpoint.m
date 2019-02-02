% Class for SPOINT entries
% Anthony Ricciardi
%
classdef BulkEntrySpoint < BulkEntry & BulkIntegerList
    
    properties
        i1 % [n,1 uint32] list of individual identification numbers and the first identification number for any THRU ranges
        iN % [n,1 uint32] list of the second identification number for any THRU ranges
        thru % [n,1 logical] true where i1(thru,1) and iN(thru,1) contain THRU ranges
    end
    methods
        function obj = BulkEntrySpoint(varargin)
            switch nargin
                case 1 % Construct using entry field data input as cell array of char
                    entryFields = varargin{1};
                    obj = obj.readIntegerFields(entryFields(2:end),'SPOINT'); % Method Inherited from BulkIntegerList
                case 3 % Construct using i1, iN, thru
                    obj.i1 = varargin{1};
                    obj.iN = varargin{2};
                    obj.thru = varargin{3};
                otherwise
                    error('Error due to number of input arguments to BulkEntrySpoint class constructor.')
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            values = obj.getValues();
            nValues = size(values,1);
            
            for i = 1:nValues
                scalarPoint(i,1) = ScalarPoint;
                scalarPoint(i,1).id = values(i);
            end
            model.point=[model.point;scalarPoint];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            obj.echoIntegerFields(fid,'SPOINT,')
        end
    end
    methods (Static = true)
        function obj = constructFromValues(values)
            % Function to construct array of BulkEntrySpoint objects using a list of SPOINT IDs
            % The THRU option is used to condense the list of values
            if size(values,2)~=1; error('''values'' input argument should be size [nValues,1].'); end
            [i1_,thru_,iN_]=BulkIntegerList.condenseFromValues(values);
            n = size(i1_,1);
            
            % create BulkEntrySpoint objects for groups of <=8 fields
            cumulativeNumberOfFields = (1:n)' + (2*cumsum(thru_));
            row = 1;
            rowIndex = zeros(n,1);
            remainingFields = true(n,1);
            while any(remainingFields)
                rowLocation = cumulativeNumberOfFields./8;
                index = rowLocation>=0 & rowLocation<1;
                rowIndex(index) = row;
                row = row + 1;
                remainingFields(index) = false;
                cumulativeNumberOfFields(index)=-1;
                cumulativeNumberOfFields(remainingFields)=...
                    cumulativeNumberOfFields(remainingFields)...
                    - min(cumulativeNumberOfFields(remainingFields))+1;
            end
            nRows = row-1;
            for row = 1:nRows
                index = rowIndex==row;
                obj(row,1) = BulkEntrySpoint(i1_(index),iN_(index),thru_(index));
            end
        end % constructFromValues()
    end   
end
