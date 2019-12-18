%Hdf5 Container and interface class for MSC Nastran format HDF5 output files.
% This class can read and write HDF5 output files. Elements data
% support is limited to element types supported by CoFE.

% A. Ricciardi
% December 2019

classdef Hdf5
    
    properties
        schema % [uint32] HDF5 data schema (developed based on MSC Nastran 2018.2)
        domains@Hdf5Domains;
        elemental@Hdf5Elemental
    end
    
    methods
        function obj = Hdf5(filename)
            
            % read and verify schema
            obj.schema = uint32(h5readatt(filename,'/','SCHEMA'));
            developementSchema = uint32(20182);
            if obj.schema ~= developementSchema
                warning('The %s HDF5 data schema is version %d. This program was developed based on schema version %s.',filename,developementSchema)
            end
            
            obj.domains=Hdf5Domains(filename);
            obj.elemental=Hdf5Elemental(filename);
        end
        function export(obj,filename)
            % create file
            fid = H5F.create(filename);
            
            % add schema attribute to root
            h5writeatt(filename,'/','SCHEMA',obj.schema);
            
            % create base groups
            plist = 'H5P_DEFAULT';
            indexId = H5G.create(fid,'INDEX',plist,plist,plist);
            indexNastranId = H5G.create(indexId,'NASTRAN',plist,plist,plist);
            indexNastranResultsId = H5G.create(indexNastranId,'RESULTS',plist,plist,plist);
            nastranId = H5G.create(fid,'NASTRAN',plist,plist,plist);
            nastranResultsId = H5G.create(nastranId,'RESULTS',plist,plist,plist);
            
            % add domains table
            obj.domains.export(nastranResultsId)            
            
            % add elemental results
            obj.elemental.export(nastranResultsId,indexNastranResultsId)  
                        
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

