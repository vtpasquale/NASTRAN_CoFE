%Hdf5Elemental MSC Nastran format HDF5 element output data container and interface class.

% A. Ricciardi
% December 2019

classdef Hdf5Elemental
    
    properties        
        hdf5ElementForce@Hdf5ElementForce;
%         hdf5Energy@Hdf5Energy
%         hdf5Strain@Hdf5Strain
%         hdf5Stress@Hdf5Stress
    end
    methods
        function obj = Hdf5Elemental(arg1)
            if ischar(arg1)% arg1 = filename
                obj.hdf5ElementForce = Hdf5ElementForce.constructFromFile(arg1);
            else
                error('Constructor not implemented for this type')
            end
        end
        function export(obj,dataGroup,indexGroup)
            
            % create element result groups
            objDataGroup  = H5G.create(dataGroup ,'ELEMENTAL','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
            objIndexGroup = H5G.create(indexGroup,'ELEMENTAL','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');

            obj.hdf5ElementForce.export(objDataGroup,objIndexGroup)
            
            % close groups
            H5G.close(objDataGroup);
            H5G.close(objIndexGroup);
        end
    end   
end

