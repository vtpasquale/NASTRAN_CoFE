classdef Hdf5ElementForce < matlab.mixin.Heterogeneous
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/ELEMENTAL/ELEMENT_FORCE/';
    end
    methods
        function objTable = getTable(obj)
            objStruct=getStruct(obj);
            objTable=struct2table(objStruct);
        end
        function writeToFile(obj,dataGroup,indexGroup)
            % create element force result groups
            objDataGroup  = H5G.create(dataGroup,'ELEMENT_FORCE','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
            objIndexGroup = H5G.create(indexGroup,'ELEMENT_FORCE','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
            
            nObj = size(obj,1);
            for i = 1:nObj
                obj(i).writeToFile_sub(objDataGroup,objIndexGroup)
            end
            
            % close groups
            H5G.close(objDataGroup);
            H5G.close(objIndexGroup);
        end
    end
    methods (Access = private)
        function writeToFile_sub(obj,dataGroup,indexGroup)
            objStruct=getStruct(obj);
            struct2hdf52(dataGroup,obj.DATASET,objStruct)
            
            indexStruct = domainId2Index(obj.DOMAIN_ID);
            struct2hdf52(indexGroup,obj.DATASET,indexStruct);
        end
        function objStruct = getStruct(obj)
            warning('off','MATLAB:structOnObject')
            objStruct=struct(obj);
            warning('on','MATLAB:structOnObject')
            objStruct=rmfield(objStruct,{'GROUP','DATASET'});
        end
    end
    methods
        function obj = constructFromFile_sub(obj,filename)
            fieldData = h5read(filename,[obj.GROUP,obj.DATASET]);
            for fn = fieldnames(fieldData)'    %enumerat fields
                obj.(fn{1}) = fieldData.(fn{1});   % copy to object properties
            end
        end
    end
    methods (Static = true)
        function hdf5ElementForce = constructFromFile(filename)
            hdf5ElementForce = Hdf5ElementForce();  %create object
                        
            info = h5info(filename,hdf5ElementForce.GROUP);
            nDatasets = size(info.Datasets,1);
            for i = 1:nDatasets
                
                % convert field 1 to case-sensitive class name
                entryName =  lower(info.Datasets(i).Name);
                entryName(1) = upper(entryName(1));
                
                % check that input entry is supported
                if exist(['Hdf5ElementForce',entryName],'class')==8
                    % Call contructor method for each entry
                    eval(['hdf5ElementForce(i,1) = Hdf5ElementForce',entryName,'(filename);']);
                else
                    warning('Hdf5 element force entry %s not supported.',upper(entryName))
                end
            end
        end
    end
    
end

