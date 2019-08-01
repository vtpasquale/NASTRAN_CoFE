% User interface class for Nastran Compatible Finite Elements (CoFE)
% Anthony Ricciardi

classdef Cofe
    properties        
        model % [nSuperElements,1 Model]
        solution % [nSubcases,nSuperElements Solution]
    end
    methods
        function [obj,varargout] = Cofe(inputFile,varargin)
            % Class constructor and primary user interface function
            %
            % REQUIRED INPUT
            % inputFile = [char] Nastran-formatted input file name.
            %
            % OPTIONAL INPUT PARAMETERS 
            % Default parameter values should be used most of the time
            % Parameters can be past as a struct or as name-value pairs
            % 
            % 'returnInputFields' = [logical, default = false]
            %                       If true, Nastran input file field data  
            %                       is returned in the second output
            %                       argument. Model preprocessing, 
            %                       assembly, solution, and hard disk 
            %                       output are suppressed.
            %
            %    'getInputFields' = [logical, default = false]
            %                       If true, Nastran input file field data  
            %                       is returned in the second output
            %                       argument.
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
            %            'output' = [logical, default = true]
            %                       Set to false to suppress hard disk 
            %                       output.
            
            % Process inputs
            p = inputParser;
            p.CaseSensitive = false;
            p.addRequired('inputFile',@ischar);
            p.addParameter('bulkDataOnly'     ,false,@islogical);
            p.addParameter('returnInputFields',false,@islogical);
            p.addParameter('getInputFields'   ,false,@islogical);
            p.addParameter('preprocess'       ,true,@islogical);
            p.addParameter('assemble'         ,true,@islogical);
            p.addParameter('solve'            ,true,@islogical);
            p.addParameter('output'           ,true,@islogical);
            p.parse(inputFile,varargin{:});
            fieldOptions = [p.Results.returnInputFields,...
                            p.Results.getInputFields];
            
            % Nastran input file processing
            bdfLines  = BdfLines(inputFile,p.Results.bulkDataOnly);
            bdfFields = BdfFields(bdfLines);
            if any(fieldOptions)
                varargout = {bdfFields};
                if fieldOptions(1); return; end
            end
            bdfEntries = BdfEntries(bdfFields);
            obj.model = bdfEntries.entries2model();
            
            % Preprocess model
            if ~p.Results.preprocess; return; end
            obj.model = obj.model.preprocess();
            
            % Assemble model
            if ~p.Results.assemble; return; end
            obj.model = obj.model.assemble();
            
            % Solve
            if ~p.Results.solve; return; end
            obj.solution = Solution.constructFromModel(obj.model);
            obj.solution = obj.solution.solve(obj.model);
            
            % Output results
            if ~p.Results.output; return; end
            obj.solution.output(inputFile,obj.model);

        end
    end
end



