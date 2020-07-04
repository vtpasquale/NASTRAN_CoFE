% User interface class for Nastran Compatible Finite Elements (CoFE)

% Anthony Ricciardi

classdef Cofe
    properties        
        model % [nSuperElements,1 Model]
        solution % [nSubcases,nSuperElements Solution]
    end
    methods
        function [obj,optional] = Cofe(inputFile,varargin)
            % Class constructor and primary user interface function.
            %
            % REQUIRED INPUT
            % inputFile = [char] Nastran-formatted input file name.
            %
            % OPTIONAL INPUT PARAMETERS 
            % Default parameter values should be used most of the time.
            % Parameters can be past as a struct or as name-value pairs.
            % 
            % 'returnInputFields' = [logical, default = false]
            %                       If true, Nastran input file field data  
            %                       is returned in the optional output
            %                       struct. Model preprocessing, 
            %                       assembly, solution, and hard disk 
            %                       output are suppressed.
            %
            %    'getInputFields' = [logical, default = false]
            %                       If true, Nastran input file field data  
            %                       is returned in the optional output
            %                       struct.
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
            %                    solution. Request using the 
            %                    'returnInputFields' or 'getInputFields' 
            %                    inputs parameters.
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
            p.addRequired('inputFile',@ischar);
            p.addParameter('bulkDataOnly'     ,false,@islogical);
            p.addParameter('returnInputFields',false,@islogical);
            p.addParameter('getInputFields'   ,false,@islogical);
            p.addParameter('preprocess'       ,true,@islogical);
            p.addParameter('assemble'         ,true,@islogical);
            p.addParameter('solve'            ,true,@islogical);
            p.addParameter('writeOutput2Disk' ,true,@islogical);
            p.addParameter('getHdf5Object'    ,false,@islogical);
            p.parse(inputFile,varargin{:});
            fieldOptions = [p.Results.returnInputFields,...
                            p.Results.getInputFields];
            
            
            %% Nastran input file processing
            bdfLines  = BdfLines(inputFile,p.Results.bulkDataOnly);
            bdfFields = BdfFields(bdfLines);
            if any(fieldOptions)
                optional.bdfFields = bdfFields;
                if fieldOptions(1); return; end
            end
            bdfEntries = BdfEntries(bdfFields);
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
            if ~p.Results.writeOutput2Disk; return; end
            [~,outputFile] = fileparts(inputFile);
            % Export Hdf5 data to hard disk
            hdf5.export([outputFile,'.h5']);
            
            % obj.solution.output(inputFile,obj.model);
        end
    end
end



