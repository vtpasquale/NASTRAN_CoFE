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
            %               OR
            %             [Model] Model object for restart. (For optimization)
            %
            % OPTIONAL INPUT PARAMETERS 
            % Default parameter values should be used most of the time.
            % Parameters can be past as a struct or as name-value pairs.
            %
            %        'stopBefore' = [char, default = '']
            %                       Stop the solution before: 'preprocess',
            %                       'entries', model, 'assemble', 
            %                       'presolve', or 'solve'.
            %
            %              'skip' = [char, default = '']
            %                       Skip solution step: 'preprocess',
            %                       'assemble'.
            %
            %      'bulkDataOnly' = [logical, default = false]
            %                       Can be set to true for reading Nastran
            %                       input files that have no Executive
            %                       Control or Case Control sections.
            %                       This option is most useful for using
            %                       CoFE to read input field data or for 
            %                       software testing.
            %
			%      'getBdfFields' = [logical, default = false]
            %                       If true, Nastran input file field data  
            %                       (BdfFields object) is returned in the
            %                        'optional' output struct.
            %
            %     'getBdfEntries' = [logical, default = false]
            %                       If true, Nastran input file entry data  
            %                       (BdfEntries object) is returned in the
            %                        'optional' output struct.
            % 
            %     'getHdf5Object' = [logical, default = false]
            %                       Set to true for Hdf5 object to be
            %                       returned in the optional output struct.
            %
            %
            %  'writeOutput2Disk' = [logical, default = true]
            %                       Set to false to suppress hard disk 
            %                       output. Forced to false if inputData is
            %                       not type char. 
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
            %        .bdfEntries [BdfEntries] Nastran input file entries 
            %                    object. This is supplemental functionality 
            %                    that is meant for users who want to use 
            %                    the BdfEntries data for their own 
            %                    processes. Request using the 
            %                    'getBdfEntries' input parameter.
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
            if ~any([ischar(inputData),isa(inputData,'BdfEntries'),isa(inputData,'Model')])
                error('Input argument ''inputData'' must be type ''char'', ''BdfEntries'', or ''Model''.')
            end
            p.addParameter('stopBefore'       ,'',@ischar);
            p.addParameter('skip'             ,'',@ischar);
            p.addParameter('bulkDataOnly'     ,false,@islogical);
            p.addParameter('getBdfFields'     ,false,@islogical);
            p.addParameter('getBdfEntries'    ,false,@islogical);
            p.addParameter('getHdf5Object'    ,false,@islogical);
            p.addParameter('writeOutput2Disk' ,true,@islogical);
            p.parse(inputData,varargin{:});            
            
            %% Input data processing
            if ischar(inputData)           
                bdfLines  = BdfLines(inputData,p.Results.bulkDataOnly);
                bdfFields = BdfFields(bdfLines);
                if p.Results.getBdfFields; optional.bdfFields = bdfFields; end
                
                if strcmpi(p.Results.stopBefore,'entries'); return; end
                bdfEntries = BdfEntries(bdfFields);
                if p.Results.getBdfEntries; optional.bdfEntries = bdfEntries; end
                
                if strcmpi(p.Results.stopBefore,'model'); return; end
                obj.model = bdfEntries.entries2model();
                writeOutput2Disk = p.Results.writeOutput2Disk;
            else
                writeOutput2Disk = false;
                if isa(inputData,'BdfEntries')
                    bdfEntries = inputData;
                    obj.model = bdfEntries.entries2model();
                elseif isa(inputData,'Model')
                    obj.model = inputData;
                else
                    error('inputData type not allowed.')
                end
            end
            
            %% Preprocess model
            if strcmpi(p.Results.stopBefore,'preprocess'); return; end
            if ~strcmpi(p.Results.skip,'preprocess')
                obj.model = obj.model.preprocess();
            end
            
            %% Assemble model
            if strcmpi(p.Results.stopBefore,'assemble'); return; end
            if ~strcmpi(p.Results.skip,'assemble')
                obj.model = obj.model.assemble();
            end
            
            %% Static solution presolve
            if strcmpi(p.Results.stopBefore,'presolve'); return; end
            if contains([obj.model(1).caseControl.analysis],'STATICS')
                obj.model(1).reducedModel=obj.model(1).reducedModel.solveUaAllLoadSets();
            end
            
            %% Solve and recover
            if strcmpi(p.Results.stopBefore,'solve'); return; end
            obj.solution = Solution.constructFromModel(obj.model);
            obj.solution = obj.solution.solve(obj.model);
                        
            %% Results
            % Create Hdf5 object from model and solution
            if p.Results.getHdf5Object || (obj.model(1).post < 1 && p.Results.writeOutput2Disk) 
                hdf5 = Hdf5(obj);
            end
            
            % Store hdf5 object in optional workspace output, if requested
            if p.Results.getHdf5Object
                optional.hdf5 = hdf5;
            end
            
            % Write output to hard disk
            if ~writeOutput2Disk; return; end
            [~,outputFile] = fileparts(inputData);
            
            % Write text output
            obj.solution.printTextOutput(obj.model,[outputFile,'.f06'])
            
            % Write Hdf5 output
            if obj.model(1).post < 1
                hdf5.export([outputFile,'.h5']);
            end
                        
        end
    end
end



