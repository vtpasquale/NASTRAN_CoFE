% Class for model nodes
% Anthony Ricciardi
%
classdef node
    
    properties
        ID  % [int] Node identification number.
        CP  % [int] Identification number of coordinate system in which the location of the node is defined.
        X_P % [3,1 Real] Location of the node in coordinate system CP.
        CD % [int]Identification number of coordinate system in which the displacements, degrees-offreedom, constraints, and solution vectors are defined at the node.
        PS % [6, 1 boolean] Permanent single-point constraints associated with nodal degrees of freedom 1-6. True if constrained.
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
            PSout = PSdefault;
        end
    end
    
end

