% Class for MAT4 entries.
% MAT4 not supported by CoFE. This class is used as a workaround for
% Femap-generated input files, which can contain MAT4 entries
% that are not used.
%
classdef BulkEntryMat4 < BulkEntry
    properties 
        mid % Material identification number. (uint32 > 0)
%         k % Thermal conductivity. (Blank or Real > 0.0)
%         cp % Heat capacity per unit mass at constant pressure (specific heat). (Blank or Real ? 0.0)
%         rho % Density. (Real > 0.0 or blank; Default = 1.0)
%         h % Free convection heat transfer coefficient. (Real or blank)
%         m % Dynamic viscosity. See Remark 2. (Real > 0.0 or blank)
%         hgen % Heat generation capability used with QVOL entries. (Real ? 0.0; Default = 1.0)
%         refenth % Reference enthalpy. (Real or blank)
%         tch % Lower temperature limit at which phase change region is to occur. (Real or blank)
%         tdelta % Total temperature change range within which a phase change is to occur. (Real ? 0.0 or blank)
%         qlat % Latent heat of fusion per unit mass associated with the phase change. (Real > 0.0 or blank)
    end
    
    methods
        function obj = BulkEntryMat4(entryFields)
            % Construct using entry field data input as cell array of char
%             obj.mid = castInputField('MAT4','MID',entryFields{2},'uint32',NaN,1);
%             obj.cp = castInputField('MAT4','CP',entryFields{3},'double',[],0.);
%             obj.rho = castInputField('MAT4','RHO',entryFields{4},'double',1.,0.);
%             obj.h = castInputField('MAT4','H',entryFields{5},'double',[]);
%             obj.m = castInputField('MAT4','M',entryFields{6},'double',[]);
        obj.mid = [];
        end
        % Write appropriate model object(s) based on entry data
        function model = entry2model_sub(obj,model)

        end
		% Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            % fprintf(fid,'MAT1,%d,%f,%f,%f,%f\n',obj.mid,obj.E,obj.G,obj.nu,obj.rho);
        end
    end
end

