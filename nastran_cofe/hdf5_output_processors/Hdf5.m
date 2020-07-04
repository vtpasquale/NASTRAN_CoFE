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
% but it is derived from stored data when the HDF5 file is exported.
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

classdef Hdf5
    
    properties
        schema = uint32(20182)% [uint32] HDF5 data schema (developed based on MSC Nastran 2018.2)
        domains@Hdf5Domains; % [Hdf5Domains] HDF5 domain data.
        elemental@Hdf5Elemental % [n,1 Hdf5Elemental] HDF5 element data.
        nodal@Hdf5Nodal % [n,1 Hdf5Nodal] HDF5 node data.
        summary@Hdf5Summary % [n,1 Hdf5Summary] HDF5 summary data.
    end
    
    methods
        function obj = Hdf5(arg1)
            % Class constructor for Hdf5. Input argument is an MSC Nastran
            % format HDF5 file or a CoFE model and solution data.
            
            if nargin>0
                if ischar(arg1)
                    obj = obj.constructFromFile(arg1);
                elseif isa(arg1,'Cofe')
                    obj = obj.constructFromCofe(arg1.model,arg1.solution);
                else
                    error('Input to Hdf5 class constructor must be empty or type char.')
                end
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
            
            % add summary results
            obj.summary.export(nastranResultsId,indexNastranResultsId)
            
            % close base groups
            H5G.close(indexNastranResultsId);
            H5G.close(indexNastranId);
            H5G.close(indexId);
            H5G.close(nastranResultsId);
            H5G.close(nastranId);
            H5F.close(fid);
        end       
        function compare(obj1,obj2)
            % Compare HDF5 objects. Used to mainly to verify CoFE solutions
            %
            % INPUTS
            % obj1 HDF5 object 1
            % obj2 HDF5 object 2
            %
            % OUTPUTS
            if obj1.schema~=obj2.schema
                warning('The HDF5 object files being compared use different schema versions. This may cause issues.')
            end
            
            % Domains - sort and compare
            obj2CompareIndex = sortCompare(obj1.domains,obj2.domains);
            
            % Node results - Eigenvector scaling

            
            % Element results
            obj1.elemental.compare(obj2.elemental,obj2CompareIndex)
            
            
            
        end
    end
    methods (Access=private)
        function obj = constructFromFile(obj,filename)
            % verify file exists (avoid the confusing HDF5 libray errors)
            if exist(filename,'file') ~= 2
                error('File "%s" not found.',filename)
            end
            
            % read and verify schema
            obj.schema = uint32(h5readatt(filename,'/','SCHEMA'));
            developementSchema = uint32(20182);
            if obj.schema ~= developementSchema
                warning('The %s HDF5 data schema is version %d. This program was developed based on schema version %d.',filename,obj.schema,developementSchema)
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
            
            % summary
            if any(strcmp({info.Groups.Name},'/NASTRAN/RESULT/SUMMARY'))
                obj.summary=Hdf5Summary.constructFromFile(filename);
            end
        end
        function obj = constructFromCofe(obj,model,solution)
            % Convert CoFE data to Hdf5 data
            %
            % INPUTS
            % model [nSuperElements,1 Model]
            % solution [nSubcases,nSuperElements Solution]
            
            % Check inputs
            [nRowsSolution,nColumnsSolution]=size(solution);
            [nModel,nColumnsModel]=size(model);
            nCases = size(model(1).caseControl,1);
            if nRowsSolution~=nCases; error('The solution object array is inconsistent with the residual structure case control array.'); end
            if nColumnsSolution~=nModel; error('nColumnsSolution~=nModel'); end
            if nColumnsModel~=1; error('nColumnsModel~=1'); end
            
            % Model superelements domain data to HDF5 subcase 0
            modelDomains = model.model2Hdf5Domains();
            obj.domains = Hdf5Domains(modelDomains);
                        
            % Append Hdf5 domain data for all analysis subcases
            for caseIndex = 1:nCases
                startDomainId = obj.domains.ID(end)+1;
                [solution(caseIndex,:),caseIndexDomains] = solution(caseIndex,:).solution2Hdf5Domains(model,startDomainId);
                obj.domains = obj.domains.appendStruct(caseIndexDomains);
            end
            
            % Create HDF5 element results data
            % pass the model object so the element classes can be found
            % without maintaining a dictionary of element types and classes
            obj.elemental = Hdf5Elemental(model,solution);
            
            % Create HDF5 nodes results data
            obj.nodal = Hdf5Nodal.constructFromCofe(solution);
            
        end
    end
end
