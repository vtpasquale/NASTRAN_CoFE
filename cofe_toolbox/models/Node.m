% Class for model nodes
% Anthony Ricciardi
%
classdef Node
    
    properties
        id  % [uint32] Node identification number.
        cp  % [uint32] Identification number of coordinate system in which the location of the node is defined.
        x_p % [3,1 double] Location of the node in coordinate system cp.
        cd % [uint32] Identification number of coordinate system in which the displacements, degrees-offreedom, constraints, and solution vectors are defined at the node.
        ps % [7, 1 logical] Permanent single-point constraints associated with nodal degrees of freedom. ps(1:6)==true where nodal degrees of freedom are perminantly constrained. ps(7)==true when the GRID ps field is not blank (default values used when GRID ps is blank - the seventh logical is needed because GRID ps=0 can be used to remove the default constraints defined on the GRDSET entry).
        
        x_0 % [3,1 double] Location of the node in the basic coordinate system.
        T_g0 % [3,3 double] Transoformation matrix from the basic coordinate system to node deformation coordinate system (defined in CD field)
    end
    methods
        function obj = preprocess(obj,model)
            % Function to preprocess nodes
            
            [nnodes,m]=size(obj);
            if m > 1; error('node.preprocess() can only handel nx1 arrays of node objects. The second dimension exceeds 1.'); end
            
            % check that element id numbers are unique
            nodeIDs = [obj.id];
            [~,ia] = unique(nodeIDs,'stable');
            if size(ia,1)~=nnodes
                nonunique=setxor(ia,1:nnodes);
                error('Node identification numbers should be unique. Nonunique node identification number(s): %s',sprintf('%d,',nodeIDs(nonunique)))
            end
            
            % Assign coordinate systems to default if unassigned
            [cpDefault,cdDefault] = obj.setGetGrdset();
            if isempty(cpDefault); cpDefault=int32(0); end
            if isempty(cdDefault); cdDefault=int32(0); end
            for i = 1:nnodes
                if isempty(obj(i).cp); obj(i).cp=cpDefault; end
                if isempty(obj(i).cd); obj(i).cd=cdDefault; end
            end
            
            % set x_0 and T_g0 for all nodes
            coordinateSystem     = model.coordinateSystem;
            coordinateSystemCIDs = model.coordinateSystemCIDs;
            for i=1:nnodes
                oi = obj(i);
                oi.x_0  = coordinateSystem(oi.cp==coordinateSystemCIDs).x_0(oi.x_p);
                nodalDispCoordSys = coordinateSystem(oi.cd==coordinateSystemCIDs);
                oi.T_g0 = nodalDispCoordSys.T_c0(nodalDispCoordSys.x_c(oi.x_0));
                obj(i)=oi;
            end
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
    end
    
end

