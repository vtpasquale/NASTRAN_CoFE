% Hdf5 domain output data.

% http://web.mscsoftware.com/doc/nastran/2018.2/release/DataType_v20182.xml
% <dataset name="DOMAINS">
% <field name="ID" description="Domain identifier" type="integer"/>
% <field name="SUBCASE" description="Subcase number" type="integer"/>
% <field name="STEP" description="Step number" type="integer"/>
% <field name="ANALYSIS" description="Analysis type" type="integer"/>
% <field name="TIME_FREQ_EIGR" description="Time, frequency or real part of eigen value" type="double"/>
% <field name="EIGI" description="Imaginary part if eigen value (if applicable)" type="double"/>
% <field name="MODE" description="Mode number" type="integer"/>
% <field name="DESIGN_CYCLE" description="Design cycle" type="integer"/>
% <field name="RANDOM" description="Random code" type="integer"/>
% <field name="SE" description="Superelement number" type="integer"/>
% <field name="AFPM" description="afpm ????" type="integer"/>
% <field name="TRMC" description="trmc ????" type="integer"/>
% <field name="INSTANCE" description="Instance" type="integer"/>
% <field name="MODULE" description="Module" type="integer"/>
% </dataset>

% A. Ricciardi
% December 2019

classdef Hdf5Domains < Hdf5CompoundDataset
    
    properties
        ID             % Domain identifier [uint32]
        SUBCASE        % Subcase number [uint32]
        STEP           % Step number [uint32]
        ANALYSIS       % Analysis type [uint32]
        TIME_FREQ_EIGR % Time, frequency or real part of eigen value [double]
        EIGI           % Imaginary part if eigen value (if applicable) [double]
        MODE           % Mode number [uint32]
        DESIGN_CYCLE   % Design cycle [uint32]
        RANDOM         % Random code [uint32]
        SE             % Superelement number [uint32]
        AFPM           % afpm ???? [uint32]
        TRMC           % trmc ???? [uint32]
        INSTANCE       % Instance [uint32]
        MODULE         % Module [uint32]
    end
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/';
        DATASET = 'DOMAINS';
        SCHEMA_VERSION = uint32(0); % MSC dataset schema version used for CoFE development
    end
%     properties (Hidden = true)
%         compareIndex % domain vector index used for comparison to another HDF5 object
%     end
    methods
        function obj = Hdf5Domains(arg1)
            if ischar(arg1)% arg1 = datasetString
                obj = obj.importCompoundDatasetFromHdf5File(arg1);
            elseif isstruct(arg1)
                obj.version = obj.SCHEMA_VERSION;
                obj=obj.appendStruct(arg1);
            else
                error('Constructor not implemented for this type')
            end
        end
        function export(obj,file)
            % Exports the dataset to an HDF5 file.
            objStruct=getStruct(obj);
            struct2hdf5(file,obj.DATASET,objStruct,obj.version)
        end
        function [obj2CompareIndex,compareExponent] = sortCompare(obj1,obj2)
            % Compare and sort HDF5 domain objects. Used to mainly for CoFE solution verification.
            n1 = size(obj1.ID,1);
            n2 = size(obj2.ID,1);
            if n1~=n2; error('HDF5 domain objects being compared are different sizes'); end
            if obj1.version~=obj2.version; warning('The HDF5 domain objects being compared use different schema versions. This may cause issues.'); end
            
            % Compare and sort using select domain integer properties
            domain1IntegerProperties = [obj1.SUBCASE,obj1.STEP,obj1.ANALYSIS,...
                obj1.MODE,obj1.DESIGN_CYCLE,obj1.RANDOM,obj1.SE];
            domain2IntegerProperties = uint32([obj2.SUBCASE,obj2.STEP,obj2.ANALYSIS,...
                obj2.MODE,obj2.DESIGN_CYCLE,obj2.RANDOM,obj2.SE]);
            % obj1.compareIndex=uint32(1:n1);
            if all(all(domain1IntegerProperties==domain2IntegerProperties))
               obj2CompareIndex=1:n1;
            else
                warning('compareWarn:hdf5_sorting','Attempting to sort HDF5 Domain objects for comparison.')
                [~,~,obj2CompareIndex]=intersect(domain1IntegerProperties,domain2IntegerProperties,'rows','stable');
                if ~all(all(domain1IntegerProperties==domain2IntegerProperties(obj2CompareIndex,:)))
                    error('Sorting for HDF5 domain comparison failed.')
                end
            end
            obj2CompareIndex=uint32(obj2CompareIndex);

            % square doubles when comparing eigenvectors
            compareExponent=ones(size(obj2CompareIndex));
            compareExponent(obj2.ANALYSIS(obj2CompareIndex)==2)=2.0;
        end
    end
end
