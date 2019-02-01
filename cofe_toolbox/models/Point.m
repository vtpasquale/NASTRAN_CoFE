% Abstract superclass for model points (i.e., nodes and scalar points)
% Anthony Ricciardi
%
classdef (Abstract) Point < matlab.mixin.Heterogeneous
    
    properties (Abstract)
        id  % [uint32] Point identification number.
    end
    methods
        function obj = preprocess(obj,model)
            % Function to preprocess points
            
            [npoints,m]=size(obj);
            if m > 1; error('point.preprocess() can only handel nx1 arrays of point objects. The second dimension exceeds 1.'); end
            
            % check that id numbers are unique
            pointIDs = [obj.id];
            [~,ia] = unique(pointIDs,'stable');
            if size(ia,1)~=npoints
                nonunique=setxor(ia,1:npoints);
                error('Node/Scalar Point identification numbers should be unique. Nonunique node identification number(s): %s',sprintf('%d,',pointIDs(nonunique)))
            end
            
            % seperate nodes for specific preprocessing
            nodeFlag = isa(obj,'Node');
            node = obj(nodeFlag);
            node = node.preprocess_sub(node,model);
            obj(nodeFlag) = node;
            
            % sort points in decending order
            
            
        end
        function model = assemble(obj,model)
            nnodes = size(obj,1);
            % Create transformation matrix from the nodal displacement
            % reference frame to the basic reference frame
            R_0g=spalloc(6*nnodes,6*nnodes,18*nnodes);
            for i = 1:nnodes
                T_0g = obj(i).T_g0.';
                R_0g(1+6*(i-1):3+6*(i-1),1+6*(i-1):3+6*(i-1))= T_0g;
                R_0g(4+6*(i-1):6+6*(i-1),4+6*(i-1):6+6*(i-1))= T_0g;
            end
            model.R_0g = R_0g;
        end
        function sg = getPerminantSinglePointConstraints(obj)
            % Process perminant single point constraints. Returns sg [nnodes,1 logical] set.
            nnodes = size(obj,1);
            
            psGrid = [obj.ps]; % ps defined by Grid entries as [7,nnodes logical] matrix.
            % psGrid(7,:) is a [1,nnodes logical] that is true if the node ps
            % values were defined explicitly. Default values are assigned where
            % psGrid(7,:)==false, explicit values where psGrid(7,:)==true.
            
            [~,~,psDefault]=obj.setGetGrdset(); % load default values from GRDSET entry
            if isempty(psDefault); psDefault=false(6,1); end
            psDefault = repmat(psDefault,[1,nnodes]); % arrange default ps values as [6,nnodes logical]
            
            ps = false(6,nnodes); % initialize ps matrix [6,nnodes logical]
            ps(:,psGrid(7,:))=psGrid(1:6,psGrid(7,:)); % apply explicitly defined ps values
            ps(:,~psGrid(7,:))=psDefault(:,~psGrid(7,:)); % apply default ps values
            sg = ps(:); % arrage sg set as [6*nnodes,1 logical]
        end
    end
    methods (Static=true)
        function [cpOut,cdOut,psOut] = setGetGrdset(cpIn,cdIn,psIn)
            % Function to store static GRDSET input data as a persistent variable
            persistent cpDefault;
            persistent cdDefault;
            persistent psDefault;
            if nargin > 0
                if nargin ~= 3; error('node.setgetGRDSET() requires zero or three input arguments'); end
                if length(cpIn)>1; error('length(cpIn) should be = 1 or 0 (blank).'); end
                if length(cdIn)>1; error('length(cdIn) should be = 1 or 0 (blank).'); end
                if ~(size(psIn,1)==6 && size(psIn,2)==1); error('size(psIn) should be a [6,1]'); end
                cpDefault = cpIn;
                cdDefault = cdIn;
                psDefault = psIn;
            end
            cpOut=cpDefault;
            cdOut=cdDefault;
            psOut=psDefault;
        end
        function solver = recover(solver,caseControl,modelNodeIDs)
            % recovers node output data
            
            
            % displacements
            if caseControl.displacement.n ~= 0
                responseType = 1; % 1=displacement
                keepIndex = caseControl.displacement.getRequestMemberIndices(modelNodeIDs,caseControl.outputSet);
                
                response = solver.u_0;
                solver.displacement_0 = NodeOutputData(responseType,response,modelNodeIDs,keepIndex);
                
                response = solver.u_g;
                solver.displacement_g = NodeOutputData(responseType,response,modelNodeIDs,keepIndex);
            end
            
            % velocities
            % accelerations
            
            % spcforces
            if caseControl.spcforces.n ~= 0
                responseType = 4; % 4=spcforces
                keepIndex = caseControl.spcforces.getRequestMemberIndices(modelNodeIDs,caseControl.outputSet);
                
                response = solver.f_0;
                solver.spcforces_0 = NodeOutputData(responseType,response,modelNodeIDs,keepIndex);
                
                response = solver.f_g;
                solver.spcforces_g = NodeOutputData(responseType,response,modelNodeIDs,keepIndex);
            end
        end
    end
end

