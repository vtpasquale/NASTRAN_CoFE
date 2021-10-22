% Abstract superclass for model points (i.e., nodes and scalar points)
% Anthony Ricciardi
%
classdef (Abstract) Point < matlab.mixin.Heterogeneous
    
    properties (Abstract)
        id  % [uint32] Point identification number.
        gdof % [n,1 uint32] index of global degrees of freedom associated with the point.
    end
    methods (Sealed = true)
        function model = preprocess(obj,model)
            % Function to preprocess points
            
            [npoints,m]=size(obj);
            if m > 1; error('point.preprocess() can only handel nx1 arrays of point objects. The second dimension exceeds 1.'); end
            
            % check that id numbers are unique
            unsortedIds = [obj.id];
            [~,ia] = unique(unsortedIds,'stable');
            if size(ia,1)~=npoints
                nonunique=setxor(ia,1:npoints);
                error('Node/Scalar Point identification numbers should be unique. Nonunique point identification number(s): %s',sprintf('%d,',unsortedIds(nonunique)))
            end
            
            % Sort points by ID
            [~,ias] = sort(unsortedIds);
            obj = obj(ias);
            
            % node specific preprocessing
            if isa(obj,'Node')
                nodeFlag = true(size(obj,1),1);
            else
                % there are scalar points (arrayfun is slow, so only run if needed.
                nodeFlag = arrayfun(@(x)isa(x,'Node'),obj);
            end
            node = obj(nodeFlag);
            node = node.preprocess_sub(model);
            obj(nodeFlag) = node;
            
            % Define global degrees of freedom
            nextGdof = uint32(1);
            for i = 1:npoints
                if nodeFlag(i) % Node
                    obj(i).gdof = nextGdof:nextGdof+5;
                    nextGdof=nextGdof+6;
                else  % Scalar Point
                    obj(i).gdof = nextGdof;
                    nextGdof=nextGdof+1;
                end
            end
            
            % save point array, IDs, nodeFlag, and nGdof to model
            model.point = obj;
            model.pointIDs = [obj.id].';
            model.nodeFlag = nodeFlag;
            model.nGdof = 6*sum(nodeFlag) + sum(~nodeFlag);
        end
        function model = assemble(obj,model)
            % Create transformation matrix from the nodal displacement
            % reference frame to the basic reference frame
            R_0g=SparseTriplet(18*model.nGdof);
            
            % transformation matrix for each grid point
            nodes = obj(model.nodeFlag);
            z3 = zeros(3);
            for i = 1:size(nodes,1)
                oi = nodes(i);
                T_0g = oi.T_g0.';
                gdof = oi.gdof;
                T_0g6 = [T_0g,z3;z3,T_0g];
                R_0g = R_0g.addMatrix(T_0g6,gdof);
            end
            
            % transformation matrix for each scalar point
            if any(~model.nodeFlag)
                scalarPoints = obj(~model.nodeFlag);
                nScalarPoints = size(scalarPoints,1);
                gdof = [scalarPoints.gdof];
                R_0g = R_0g.addMatrix(eye(nScalarPoints),gdof);
            end
            
            % save to model
            model.R_0g = R_0g.convertToSparseMatrix(model.nGdof,model.nGdof);
        end % assemble()
        function point = getPoint(obj,id,model)
            % returns a single point object with the requested id from the point array
            index = (id == model.pointIDs);
            if ~any(index)
                error('Grid/Scalar point ID = %d is referenced, but is undefined.',id);
            end
            point = obj(index);
            if size(point,1)~=1
                error('Grid/Scalar point ID = %d is defined more than once.',id)
            end
        end % getPoint()
        function point = getPoints(obj,id,model)
            % Returns array of point objects with the requested ids from the point array
            % The points are returned in the order requested (not sorted) 
            [~,~,ib] = intersect(id,model.pointIDs,'stable');
            point = obj(ib);
            if size(point,1)~=size(id,1)
                error('There is an issue identifying points.')
            end
            if any([point.id]'~=id)
                error('There is an issue identifying points.')
            end
        end % getPoints()
        function node  = getNode(obj,id,model)
            % returns a single node object with the requested node id from the point array
            index = (id == model.pointIDs);
            if ~any(index)
                error('Grid point ID = %d is referenced, but is undefined.',id);
            end
            node = obj(index);
            if ~isa(node,'Node')
                error('Grid point ID = %d is referenced, but a scalar point with that id was found.',id);
            end
            if size(node,1)~=1
                error('Node/Scalar point ID = %d is defined more than once.',id)
            end
        end % getNode ()
        function scalarPoint = getScalarPoint(obj,id,model)
            % returns a single Scalar Point object with the requested point id from the point array
            index = (id == model.pointIDs);
            if ~any(index)
                error('Scalar point ID = %d is referenced, but is undefined.',id);
            end
            scalarPoint = obj(index);
            if ~isa(scalarPoint,'ScalarPoint')
                error('Scalar point ID = %d is referenced, but a Grid point with that id was found.',id);
            end
            if size(scalarPoint,1)~=1
                error('Grid/Scalar point ID = %d is defined more than once.',id)
            end
        end % getScalarPoint ()
        function sg = getPerminantSinglePointConstraints(obj,model)
            % Process perminant single point constraints. Returns sg [nGdof,1 logical] set.
            node = obj(model.nodeFlag);
            nNodes = size(node,1);
            
            psGrid = [node.ps]; % ps defined by Grid entries as [7,nnodes logical] matrix.
            % psGrid(7,:) is a [1,nnodes logical] that is true if the node ps
            % values were defined explicitly. Default values are assigned where
            % psGrid(7,:)==false, explicit values where psGrid(7,:)==true.
            
            psDefaultAll = repmat(model.psDefault,[1,nNodes]); % arrange default ps values as [6,nnodes logical]
            psNodes = false(6,nNodes); % initialize matrix [6,nnodes logical]
            psNodes(:,psGrid(7,:))=psGrid(1:6,psGrid(7,:)); % apply explicitly defined Grid ps values
            psNodes(:,~psGrid(7,:))=psDefaultAll(:,~psGrid(7,:)); % apply default Grid ps values
            sgNodes = psNodes(:); % arrage Nodes sg set
            
            % merge with scalar points
            sg = false(model.nGdof,1); % initialize sg set
            sg([node.gdof]) = sgNodes; % apply node ps values
        end
    end
    methods (Static=true)
        function solution = recover(solution,model)
            % Function to recover point quantities from solution.
            % This method is called speratly for each superelement and
            % seperatly for each subcase.
            %
            % INPUTS
            % solution = [1,1 Solution] Solution object without recovered output data
            % model = [1,1 Model] 
            % 
            %
            % OUTPUT
            % solution = [1,1 Solution] Solution object with recovered output data
            
            % recovers node output data
            caseControl = model.caseControl(solution.caseControlIndex);

            % displacements
            if caseControl.displacement.n ~= 0
                responseType = 1; % 1=displacement
                keepIndex = caseControl.displacement.getRequestMemberIndices(model.pointIDs,caseControl.outputSet);
                
                response = solution.u_g;
                solution.displacement = PointOutputData(responseType,response,model,keepIndex);
            end
            
            % velocities
            % accelerations
            
            % spcforces
            if caseControl.spcforces.n ~= 0
                responseType = 4; % 4=spcforces
                keepIndex = caseControl.spcforces.getRequestMemberIndices(model.pointIDs,caseControl.outputSet);
                
                response = solution.f_g;
                solution.spcforces = PointOutputData(responseType,response,model,keepIndex);
            end
        end % recover()
    end
end

