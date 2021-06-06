% User interface class for Nastran Compatible Finite Elements (CoFE)

% Anthony Ricciardi

classdef Cofe
    properties        
        model % [nSuperElements,1 Model]
        solution % [nSubcases,nSuperElements Solution]
    end
    methods
        function [obj,optional] = Cofe(inputData,varargin)
            % Class constructor and primary user interface function.
            %
            % REQUIRED INPUT
            % inputData = [char] Nastran-formatted input file name. (Typical)
            %               OR
            %             [BdfEntries] BdfEntries object for restart. (For optimization)
            %
            % OPTIONAL INPUT PARAMETERS 
            % Default parameter values should be used most of the time.
            % Parameters can be past as a struct or as name-value pairs.
            %
            %      'getBdfFields' = [logical, default = false]
            %                       If true, Nastran input file field data  
            %                       (BdfFields object) is returned in the
            %                        'optional' output struct.
            %
            %   'stopAfterFields' = [logical, default = false]
            %                       If true, CoFE will stop immidiately
            %                       after processing the input file fields.
            %
            %     'getBdfEntries' = [logical, default = false]
            %                       If true, Nastran input file entry data  
            %                       (BdfEntries object) is returned in the
            %                        'optional' output struct.
            %
            %  'stopAfterEntries' = [logical, default = false]
            %                       If true, CoFE will stop immidiately
            %                       after processing the input file entries.
            %
            %      'bulkDataOnly' = [logical, default = false]
            %                       Can be set to true for reading Nastran
            %                       input files that have no Executive
            %                       Control or Case Control sections.
            %                       This option is most useful for using
            %                       CoFE to read input field data or for 
            %                       software testing.
            % 
            %        'preprocess' = [logical, default = true]
            %                       Set to false to suppress model
            %                       preprocessing, assembly, solution, and
            %                       hard disk output.
            %                       
            %          'assemble' = [logical, default = true]
            %                       Set to false to suppress model
            %                       assembly, solution, and hard disk 
            %                       output.
            %
            %             'solve' = [logical, default = true]
            %                       Set to false to suppress model
            %                       solution and hard disk output.
            %
            %  'writeOutput2Disk' = [logical, default = true]
            %                       Set to false to suppress hard disk 
            %                       output.
            % 
            %     'getHdf5Object' = [logical, default = false]
            %                       Set to true for Hdf5 object to be
            %                       returned in the optional output struct.
            %
            % OPTIONAL OUTPUT
            % optional.[struct] optional output. Fields: 
            %
            %         .bdfFields [BdfFields] Nastran input file fields 
            %                    object. This is supplemental functionality 
            %                    that is meant for users who want to parse 
            %                    a Nastran input file using CoFE but not 
            %                    necessarily use CoFE for the analysis
            %                    solution. Request using the 'getBdfFields' 
            %                    input parameter.
            %
            %         .bdfFields [BdfFields] Nastran input file fields 
            %                    object. This is supplemental functionality 
            %                    that is meant for users who want to parse 
            %                    a Nastran input file using CoFE but not 
            %                    necessarily use CoFE for the analysis
            %                    solution. Request using the 'getBdfFields' 
            %                    input parameter.
            %
            %          .hdf5 [Hdf5] Container and interface class for HDF5  
            %                output file in MSC Nastran format. Usually it  
            %                makes sense for the file to be written to hard
            %                disk, so this optional argument is intended 
            %                for special cases. Request using the
            %                'getHdf5Object' inputs parameter.
            
            optional = [];
            
            %% Process function inputs
            p = inputParser;
            p.CaseSensitive = false;
            p.addRequired('inputData');
            if ~any([ischar(inputData),isa(inputData,'BdfEntries')])
                error('Input argument ''inputData'' must be type ''char'' or type ''BdfEntries''.')
            end
            p.addParameter('bulkDataOnly'     ,false,@islogical);
            p.addParameter('getBdfFields'     ,false,@islogical);
            p.addParameter('stopAfterFields'  ,false,@islogical);
            p.addParameter('getBdfEntries'    ,false,@islogical);
            p.addParameter('stopAfterEntries' ,false,@islogical);
            p.addParameter('preprocess'       ,true,@islogical);
            p.addParameter('assemble'         ,true,@islogical);
            p.addParameter('solve'            ,true,@islogical);
            p.addParameter('writeOutput2Disk' ,true,@islogical);
            p.addParameter('getHdf5Object'    ,false,@islogical);
            p.parse(inputData,varargin{:});            
            
            %% Input data processing
            if ischar(inputData)
                bdfLines  = BdfLines(inputData,p.Results.bulkDataOnly);
                
                bdfFields = BdfFields(bdfLines);
                if p.Results.getBdfFields; optional.bdfFields = bdfFields; end
                if p.Results.stopAfterFields; return; end
                
                bdfEntries = BdfEntries(bdfFields);
                if p.Results.getBdfEntries; optional.bdfEntries = bdfEntries; end
                if p.Results.stopAfterEntries; return; end
                
                writeOutput2Disk = p.Results.writeOutput2Disk;
            else
                bdfEntries = inputData;
                writeOutput2Disk = false;
            end
            obj.model = bdfEntries.entries2model();
            
            %% Preprocess model
            if ~p.Results.preprocess; return; end
            obj.model = obj.model.preprocess();
            
            %% Assemble model
            if ~p.Results.assemble; return; end
            obj.model = obj.model.assemble();
            
            %% Solve
            if ~p.Results.solve; return; end
            obj.solution = Solution.constructFromModel(obj.model);
            obj.solution = obj.solution.solve(obj.model);
            
            %% Results
            % Create Hdf5 object from model and solution
            if p.Results.writeOutput2Disk || p.Results.getHdf5Object
                hdf5 = Hdf5(obj);
            end
            
            % Store hdf5 object in optional workspace output, if requested
            if p.Results.getHdf5Object
                optional.hdf5 = hdf5;
            end
            
            % Write output to hard disk
            if ~writeOutput2Disk; return; end
            [~,outputFile] = fileparts(inputFile);
            % Export Hdf5 data to hard disk
            hdf5.export([outputFile,'.h5']);
            
            % obj.solution.output(inputFile,obj.model);
        end
    end
end



