% User interface class for Nastran Compatible Finite Elements (CoFE)
% Anthony Ricciardi

% ---------------------------------------------------------------------------
%    Copyright (c) 2019 Anthony Ricciardi <pasquale@vt.edu>
%
%    Permission is hereby granted, free of charge, to any person obtaining a copy
%    of this software and associated documentation files (the "Software"), to deal
%    in the Software without restriction, including without limitation the rights
%    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%    copies of the Software, and to permit persons to whom the Software is
%    furnished to do so, subject to the following conditions:
%
%    The above copyright notice and this permission notice shall be included in all
%    copies or substantial portions of the Software.
%
%    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%    SOFTWARE.
%  ---------------------------------------------------------------------------
%
%   PUBLICATION
%   The Software was originally created to produce results for:
%
%   Ricciardi, A. P., Canfield, R. A., Patil, M. P., and Lindsley, N.,
%   ``Nonlinear Aeroelastic Scaled-Model Design,'' doi: 10.2514/1.C033171.
%   Journal of Aircraft, Vol. 53, No. 1 (2016), pp. 20-32.
%
%   Please cite the associated source if this software is used for published
%   work.
%
%  --------------------------------------------------------------------------
%
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



