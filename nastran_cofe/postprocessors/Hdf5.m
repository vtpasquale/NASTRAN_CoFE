classdef Hdf5
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        domains@Hdf5Domains;
        elemental@Hdf5Elemental
    end
    
    methods (Static = true)
        function obj = constructFromFile(filename)
            obj = Hdf5();  %create object
            obj.domains=Hdf5Domains.constructFromFile(filename);
            obj.elemental=Hdf5Elemental.constructFromFile(filename);
        end
    end
    methods
        function writeToFile(obj,filename)
            % create file
            fid = H5F.create(filename);
            
            % create base groups
            plist = 'H5P_DEFAULT';
            indexId = H5G.create(fid,'INDEX',plist,plist,plist);
            indexNastranId = H5G.create(indexId,'NASTRAN',plist,plist,plist);
            indexNastranResultsId = H5G.create(indexNastranId,'RESULTS',plist,plist,plist);
            nastranId = H5G.create(fid,'NASTRAN',plist,plist,plist);
            nastranResultsId = H5G.create(nastranId,'RESULTS',plist,plist,plist);
            
            % add domains table
            obj.domains.writeToFile(nastranResultsId)            
            
            % add elemental results
            obj.elemental.writeToFile(nastranResultsId,indexNastranResultsId)  
                        
            % close base groups
            H5G.close(indexNastranResultsId);
            H5G.close(indexNastranId);
            H5G.close(indexId);
            H5G.close(nastranResultsId);
            H5G.close(nastranId);
            H5F.close(fid);
        end
    end
    
end

