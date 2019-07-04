% User interface class for Nastran Compatible Finite Elements (CoFE)
% Anthony Ricciardi

classdef Cofe
    properties        
        model % [nSuperElements,1 Model]
        solution % [nSubcases,nSuperElements Solution]
    end
    methods
        function obj = Cofe(inputFile)
            % Class constructor and primary user interface function
            %
            % INPUTS
            % inputFile = [char] Nastran-formatted input file name.

            
            % Input file processing
            bdfLines  = BdfLines(inputFile);
            bdfFields = BdfFields(bdfLines);
            bdfEntries = BdfEntries(bdfFields);
            obj.model = bdfEntries.entries2model();
            
            % Assemble model
            obj.model = obj.model.preprocess();
            obj.model = obj.model.assemble();
            
            % Solve
            obj.solution = Solution.constructFromModel(obj.model);
            obj.solution = obj.solution.solve(obj.model);
            
            % Output results
            obj.solution.output(inputFile,obj.model);
            

        end
    end
end



