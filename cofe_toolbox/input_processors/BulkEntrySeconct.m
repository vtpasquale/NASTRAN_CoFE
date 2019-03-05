% Class for SECONCT entries
% Anthony Ricciardi
%
classdef BulkEntrySeconct < BulkEntry & IntegerList
    
    properties
        seida % [uint32 > 0] Partitioned super element identification number.
        seidb % [unit32 >=0] Identification number of superelement for connection to SEIDA.
        tol % [double] Location tolerance to be used when searching for boundary grid points. (Default=10E-5)
        loc % [char] Coincident location check option for manual connection option: 'YES' or 'NO' (Default='YES')
        
        %% Properties from IntegerList
        i1 % [n,1 uint32] list of individual identification numbers and the first identification number for any THRU ranges
        iN % [n,1 uint32] list of the second identification number for any THRU ranges
        thru % [n,1 logical] true where i1(thru,1) and iN(thru,1) contain THRU ranges
        
    end
    methods
        function obj = BulkEntrySeconct(entryFields)
            % Construct using entry field data input as cell array of char
            obj.seida = castInputField('SECONCT','SEIDA',entryFields{2},'uint32',NaN,1);
            obj.seidb = castInputField('SECONCT','SEIDB',entryFields{3},'uint32',NaN,0);
            obj.tol = castInputField('SECONCT','TOL',entryFields{4},'double',1E-4);
            obj.loc = castInputField('SECONCT','LOC',entryFields{5},'char',[],'YES');
            obj = obj.readIntegerFields(entryFields(12:end),'SECONCT');
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            % Check options are supported
            gida = [];
            gidb = [];
            n = size(obj.i1,1);
            i = 1;
            while i < n
                if obj.thru(i)
                    gida=[gida,obj.i1(i):obj.iN(i)];
                    i = i + 1;
                    gidb=[gidb,obj.i1(i):obj.iN(i)];
                    i = i + 1;
                else
                    gida=[gida,obj.i1(i)];
                    i = i + 1;
                    gidb=[gidb,obj.i1(i)];
                    i = i + 1;
                end
            end
            model.superElement=model.superElement.setSeconct(obj.seida,obj.seidb,gida.',gidb.');
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            startFields=sprintf('SECONCT,%d,%d,%E,%s,,,,,',obj.seida,obj.seidb,obj.tol,obj.loc);
            echoIntegerFields(obj,fid,startFields)
        end
        
    end
end

