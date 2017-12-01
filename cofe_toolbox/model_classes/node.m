% Class for model nodes
% Anthony Ricciardi
%
classdef node
    
    properties
        ID  % [int] Node identification number.
        CP  % [int] Identification number of coordinate system in which the location of the node is defined.
        X_P % [3,1 real] Location of the node in coordinate system CP.
        CD % [int] Identification number of coordinate system in which the displacements, degrees-offreedom, constraints, and solution vectors are defined at the node.
        PS % [7, 1 logical] Permanent single-point constraints associated with nodal degrees of freedom. PS(1:6)==true where nodal degrees of freedom are perminantly constrained. PS(7)==true when the GRID PS field is not blank (default values used when GRID PS is blank - the seventh logical is needed because GRID PS=0 can be used to remove the default constraints defined on the GRDSET entry).
    end
    methods
        function obj = preprocess(obj)
            % Function to preprocess nodes            
            
            % check that element id numbers are unique
            NIDS = [obj.ID];
            nnodes = size(obj,1);
            [~,ia] = unique(NIDS,'stable');
            if size(ia,1)~=nnodes
                nonunique=setxor(ia,1:nnodes);
                error('Node identification numbers should be unique. Nonunique node identification number(s): %s',sprintf('%d,',NIDS(nonunique)))
            end
        end
        function sg = process_ps(obj)
            % Process perminant single point constraints. Returns sg [nnodes,1 logical] set.
            nnodes = size(obj,1);
            
            psGrid = [obj.PS]; % ps defined by Grid entries as [7,nnodes logical] matrix.
            % psGrid(7,:) is a [1,nnodes logical] that is true if the node ps
            % values were defined explicitly. Default values are assigned where
            % psGrid(7,:)==false, explicit values where psGrid(7,:)==true.
            
            [~,~,PSdefault]=obj.setgetGRDSET(); % load default values from GRDSET entry
            psDefault = repmat(PSdefault,[1,nnodes]); % arrange default ps values as [6,nnodes logical]
            
            ps = false(6,nnodes); % initialize ps matrix [6,nnodes logical]
            ps(:,psGrid(7,:))=psGrid(1:6,psGrid(7,:)); % apply explicitly defined ps values
            ps(:,~psGrid(7,:))=psDefault(:,~psGrid(7,:)); % apply default ps values
            sg = ps(:); % arrage sg set as [6*nnodes,1 logical]
        end
    end
    methods (Static=true)
        function [CPout,CDout,PSout] = setgetGRDSET(CPin,CDin,PSin)
            % Function to store static GRDSET data as a persistent variable
            persistent CPdefault;
            persistent CDdefault;
            persistent PSdefault;
            if nargin > 0
                if nargin ~= 3; error('node.setgetGRDSET() requires zero or three input arguments'); end
                if length(CPin)>1; error('length(CPin) should be = 1 or 0 (blank).'); end
                if length(CDin)>1; error('length(CDin) should be = 1 or 0 (blank).'); end
                if ~(size(PSin,1)==6 && size(PSin,2)==1); error('size(PSin) should be a [6,1]'); end
                CPdefault = CPin;
                CDdefault = CDin;
                PSdefault = PSin;
            end
            CPout=CPdefault;
            CDout=CDdefault;
            PSout=PSdefault;
        end
    end
    
end

