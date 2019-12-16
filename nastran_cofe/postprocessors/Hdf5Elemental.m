classdef Hdf5Elemental
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        hdf5ElementForce@Hdf5ElementForce;
%         hdf5Energy@Hdf5Energy
%         hdf5Strain@Hdf5Strain
%         hdf5Stress@Hdf5Stress
    end
    methods
        function writeToFile(obj,dataGroup,indexGroup)
            
            % create element result groups
            objDataGroup  = H5G.create(dataGroup ,'ELEMENTAL','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
            objIndexGroup = H5G.create(indexGroup,'ELEMENTAL','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');

            obj.hdf5ElementForce.writeToFile(objDataGroup,objIndexGroup)
            
            % close groups
            H5G.close(objDataGroup);
            H5G.close(objIndexGroup);
        end
    end
    methods (Static = true)
        function obj = constructFromFile(filename)
            obj = Hdf5Elemental();  %create object
            obj.hdf5ElementForce = Hdf5ElementForce.constructFromFile(filename);
        end
    end
    
end

