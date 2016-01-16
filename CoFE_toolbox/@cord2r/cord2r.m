% Class for CORD2R entries
% Defines a rectangular coordinate system using the coordinates of three points.
% Anthony Ricciardi
%
classdef cord2r < entry
    
    % input data
    properties
        CID
        A
        B
        C
    end
    
    properties (Access = private)
        R % [3x3] rotation matrix from element to global reference frame
    end
    
    methods
        
        %%
        function obj = initialize(obj,data)
            obj.CID = set_data('CORD2R','CID',data{2},'int',[],1);
            RID = set_data('CORD2R','RID',data{3},'int',0,0);
            if RID ~= 0
                error(['CORD2R ',num2str(obj.CID),'has nonzero RID.  RID must be zero or blank.']);
            end
            obj.A = zeros(3,1);
            obj.B = zeros(3,1);
            obj.C = zeros(3,1);
            obj.A(1) = set_data('CORD2R','A1',data{4},'dec',[]);
            obj.A(2) = set_data('CORD2R','A2',data{5},'dec',[]);
            obj.A(3) = set_data('CORD2R','A3',data{6},'dec',[]);
            obj.B(1) = set_data('CORD2R','B1',data{7},'dec',[]);
            obj.B(2) = set_data('CORD2R','B2',data{8},'dec',[]);
            obj.B(3) = set_data('CORD2R','B3',data{9},'dec',[]);
            obj.C(1) = set_data('CORD2R','C1',data{12},'dec',[]);
            obj.C(2) = set_data('CORD2R','C2',data{13},'dec',[]);
            obj.C(3) = set_data('CORD2R','C3',data{14},'dec',[]);
            
            dAB = obj.B-obj.A;
            nu = (obj.C-obj.A);
            
            if (dAB < 1e5*eps) | (nu < 1e5*eps)
                error(['CORD2R ',num2str(obj.CID),'has coincident or close to coincident points.']);
            end
            
            z = dAB./norm_cs(dAB);
            y = cross3(z,nu); y = y./norm(y);
            x = cross3(y,z); x = x./norm(x);
            
            obj.R = [x,y,z];
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'CORD2R,%d,,%f,%f,%f,%f,%f,%f\n',obj.CID,obj.A',obj.B');
            fprintf(fid,',%f,%f,%f\n',obj.C');
        end
        
        %%
        function pnew = rot(obj,p)
            pnew = obj.R*p + obj.A;
        end
    end
end

%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end
%% cheaper 3x3 Cross product
function p = cross3(u,v)
    p = [u(2)*v(3); u(3)*v(1); u(1)*v(2)]-[u(3)*v(2); u(1)*v(3); u(2)*v(1)];
end