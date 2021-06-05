%Hdf5Elemental Container and interface class for element output data.

% A. Ricciardi
% December 2019

classdef Hdf5Elemental
    
    properties        
        hdf5ElementForce@Hdf5ElementForce;
        hdf5ElementEnergy@Hdf5ElementEnergy;
        hdf5ElementStrain@Hdf5ElementStrain
        hdf5ElementStress@Hdf5ElementStress
    end
    methods
        function obj = Hdf5Elemental(arg1,arg2)
            if ischar(arg1)% arg1 = filename
                obj.hdf5ElementForce = Hdf5ElementForce.constructFromFile(arg1);
                obj.hdf5ElementEnergy = Hdf5ElementEnergy.constructFromFile(arg1);
                obj.hdf5ElementStrain = Hdf5ElementStrain.constructFromFile(arg1);
                obj.hdf5ElementStress = Hdf5ElementStress.constructFromFile(arg1);
            elseif isa(arg1,'Model')
                obj.hdf5ElementForce = Hdf5ElementForce.constructFromCofe(arg1,arg2);
                obj.hdf5ElementEnergy = Hdf5ElementEnergy.constructFromCofe(arg1,arg2);
                obj.hdf5ElementStrain = Hdf5ElementStrain.constructFromCofe(arg1,arg2);
                obj.hdf5ElementStress = Hdf5ElementStress.constructFromCofe(arg1,arg2);
            else
                error('Constructor not implemented for this type')
            end
        end
        function export(obj,dataGroup,indexGroup)
            if size(obj,1)>0
                % create element result groups
                objDataGroup  = H5G.create(dataGroup ,'ELEMENTAL','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                objIndexGroup = H5G.create(indexGroup,'ELEMENTAL','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                
                obj.hdf5ElementForce.export(objDataGroup,objIndexGroup)
                obj.hdf5ElementEnergy.export(objDataGroup,objIndexGroup)
                obj.hdf5ElementStrain.export(objDataGroup,objIndexGroup)
                obj.hdf5ElementStress.export(objDataGroup,objIndexGroup)
                
                % close groups
                H5G.close(objDataGroup);
                H5G.close(objIndexGroup);
            end
        end
        function compare(obj1,obj2,obj2index,compareExponent)
            % Function to compare objects
            obj1.hdf5ElementForce.compare(obj2.hdf5ElementForce,obj2index,compareExponent)
            obj1.hdf5ElementEnergy.compare(obj2.hdf5ElementEnergy,obj2index,compareExponent)
            obj1.hdf5ElementStrain.compare(obj2.hdf5ElementStrain,obj2index,compareExponent)
            obj1.hdf5ElementStress.compare(obj2.hdf5ElementStress,obj2index,compareExponent)
        end
    end   
end

