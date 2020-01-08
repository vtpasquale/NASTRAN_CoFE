% Container and interface class for MSC Nastran format HDF5 output files.
% This class can read, write, and compare HDF5 output files. Element data 
% support is limited to element types supported by CoFE.
%
% This class is designed to be useful for CoFE postprocessing and
% verification. The entire HDF5 data set is stored in memory, which is 
% suitable for the modest size models that work well with CoFE. However,
% MSC Nastran can process enormous models and create output data sets that
% will not fit in memory. HDF5 import will fail for cases where the data is
% too large to fit in memory; this is a hardware-dependant limitation.
%
% The current implemenation of this class contains and interfaces with
% classes that represent the data stored in Group '/NASTRAN/RESULT'.
% Corresponding data in Group '/INDEX' is dependent data; it is not stored,
% but it is derived when the HDF5 file is exported. 
%
% HDF5 **.h5
% Group '/NASTRAN' 
%     Group '/NASTRAN/RESULT' 
%         Dataset 'DOMAINS' 
%         Group '/NASTRAN/RESULT/ELEMENTAL' 
%         Group '/NASTRAN/RESULT/NODAL' 
%         Group '/NASTRAN/RESULT/SUMMARY' 
% 
% Group '/INDEX' 
%     Group '/INDEX/NASTRAN' 
%    [mirrors /NASTRAN with corresponding index data. Index data are not 
%     stored but are derived and exported during HDF5 export.]
 
% A. Ricciardi
% December 2019

classdef Hdf5
    
    properties
        schema % [uint32] HDF5 data schema (developed based on MSC Nastran 2018.2)
        domains@Hdf5Domains; % [Hdf5Domains] HDF5 domain data.
        elemental@Hdf5Elemental % [n,1 Hdf5Elemental] HDF5 element data.
        nodal@Hdf5Nodal % [n,1 Hdf5Nodal] HDF5 node data.
        summary@Hdf5Summary % [n,1 Hdf5Summary] HDF5 summary data.
    end
    
    methods
        function obj = Hdf5(filename)
            
            % verify file exists (avoid confusing HDF5 libary errors)
            if exist(filename,'file') ~= 2
                error('File "%s" not found.',filename)
            end
            
            % read and verify schema
            obj.schema = uint32(h5readatt(filename,'/','SCHEMA'));
            developementSchema = uint32(20182);
            if obj.schema ~= developementSchema
                warning('The %s HDF5 data schema is version %d. This program was developed based on schema version %s.',filename,developementSchema)
            end
            
            % read results
            info = h5info(filename,'/NASTRAN/RESULT/');
            
            % domains
            obj.domains=Hdf5Domains(filename);
            
            % elements
            if any(strcmp({info.Groups.Name},'/NASTRAN/RESULT/ELEMENTAL'))
                obj.elemental=Hdf5Elemental(filename);
            end
            
            % nodes
            if any(strcmp({info.Groups.Name},'/NASTRAN/RESULT/NODAL'))
                obj.nodal=Hdf5Nodal.constructFromFile(filename);
            end
            
            % nodes
            if any(strcmp({info.Groups.Name},'/NASTRAN/RESULT/SUMMARY'))
                obj.summary=Hdf5Summary.constructFromFile(filename);
            end
            
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
            indexNastranResultsId = H5G.create(indexNastranId,'RESULT',plist,plist,plist);
            nastranId = H5G.create(fid,'NASTRAN',plist,plist,plist);
            nastranResultsId = H5G.create(nastranId,'RESULT',plist,plist,plist);
            
            % add domains
            obj.domains.export(nastranResultsId)
            
            % add elemental results
            obj.elemental.export(nastranResultsId,indexNastranResultsId)
            
            % add nodal results
            obj.nodal.export(nastranResultsId,indexNastranResultsId)

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

