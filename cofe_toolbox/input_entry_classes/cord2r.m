% Defines a rectangular coordinate system using the coordinates of three points.
% Anthony Ricciardi
%
classdef cord2r < cordr & cord2
    
    properties
        CID % (Integer > 0) Coordinate system identification number. 
        RID % (Integer > 0; Default = 0; which is the basic coordinate system.) Identification number of a coordinate system that is defined independently from this coordinate system. 
        A % ([3,1] Float) Coordinates of point A in coordinate system RID.
        B % ([3,1] Float) Coordinates of point B in coordinate system RID. 
        C % ([3,1] Float) Coordinates of point C in coordinate system RID.
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
        TC_C0 % ([3,3] Symmetric Float) Transformation matrix from basic coordinate system to current coordinate system at current coordinate system origin
    end
    
    methods
        %% Inherits from cordr
        % function XP_0 = XP_0(XP_C) % Returns location XP ([3,1] Float) expressed in _0 from XP expressed in _C
        % function XP_C = XP_C(XP_0) % Returns location XP ([3,1] Float) expressed in _C from XP expressed in _0
        % function T_C0 = T_C0(XP_C) % Returns transformation matrix ([3,3] Symmetric Float) from basic coordinate system to current coordinate system at XP_C
        
        %% Inherits from cord2
        % function obj = initialize(obj,data) % Initialize property values based on bulk data inputs
        % function obj = preprocess(obj,Robj) % Preprocess coordinate system
        
        %%
        function echo(obj,fid)
            % Echo bulk data entry
            fprintf(fid,'CORD2R,%d,%d,%f,%f,%f,%f,%f,%f\n',obj.CID,obj.RID,obj.A',obj.B');
            fprintf(fid,',%f,%f,%f\n',obj.C');
        end
        
    end
end