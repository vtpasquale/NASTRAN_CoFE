% Class for case control
% Anthony Ricciardi
%
classdef CaseControl
    
    properties
        superelement; %  [n,1 int32] Vector of superelement identification numbers OR -1 for all superelements.
        loadSequence; % [uint32] Superelement load sequence number.
        subcase; % [uint32] Subcase identification number.
        analysis; % [char] Specifies the type of analysis being performed for the current subcase

        % Titles
        title=''; % [char] Defines a title to appear on the first heading line of each page
        subtitle=''; % [char] Defines a subtitle to appear on the second heading line of each page
        label=''; % [char] Defines a label to appear on the third heading line of each page
        
        % Analysis selections
        spc % (int > 0 or blank) Selects a single point constraint set to be applied
        load % (int > 0 or blank) Selects a load set to be applied
        method % (int > 0 or blank) Selects the real eigenvalue extraction parameters
        
        % Output sets
        outputSet@OutputSet; % [nsets,1] Array of OutputSet objects
        
        % Nodal response output requests
        displacement = OutputRequest(); % [OutputRequest] Requests the form and type of nodal displacement output
        velocity     = OutputRequest(); % [OutputRequest] Requests the form and type of nodal velocity output
        acceleration = OutputRequest(); % [OutputRequest] Requests the form and type of nodal acceleration output
        spcforces    = OutputRequest(); % [OutputRequest] Requests the form and type of single-point force of constraint vector output
        
        % Element response output requests
        force  = OutputRequest(); % [OutputRequest] Requests the form and type of element force output
        stress = OutputRequest(); % [OutputRequest] Requests the form and type of element stress output
        strain = OutputRequest(); % [OutputRequest] Requests the form and type of element strain output
        ese    = OutputRequest(); % [OutputRequest] Requests the form and type of element strain energy output
        eke    = OutputRequest(); % [OutputRequest] Requests the form and type of element kinetic energy output
    end
    
    methods
       
        %% Set Methods
        function obj = set.analysis(obj,in)
            if ischar(in)==0; error('CaseControl.ANALYSIS must be a string'); end
            opts = {'STATICS','MODES','BUCK'};
            switch in
                case opts
                otherwise
                    error('Case control ''ANALYSIS = %s'' not supported.',in)
            end
            obj.analysis=in;
        end
        function obj = set.title(obj,in)
            if ischar(in)==0; error('CaseControl.title must be type char'); end
            obj.title=in;
        end
        function obj = set.subtitle(obj,in)
            if ischar(in)==0; error('CaseControl.subtitle must be type char'); end
            obj.subtitle=in;
        end
        function obj = set.label(obj,in)
            if ischar(in)==0; error('CaseControl.LABEL must be type char'); end
            obj.label=in;
        end
        function obj = set.outputSet(obj,in)
            if isa(in,'OutputSet')==0; error('CaseControl.outputSet must be an instanct of Class OutputSet'); end
            [~,m]=size(in);
            if m~=1; error('Array instances of Class output_set should have size(outputSet,2)==1.'); end
            obj.outputSet=in;
        end
        function obj = set.spc(obj,in)
            obj.spc=setInt(in,'CaseControl.spc');
        end
        function obj = set.load(obj,in)
            obj.load=setInt(in,'CaseControl.load');
        end
        function obj = set.method(obj,in)
            obj.method=setInt(in,'CaseControl.method');
        end  
        
        %% 
        function model = caseControl2model(obj,model,modelSuperElementID)
            % Function to deal array of case control objects to array of
            % Model objects according to superelement applicability
            
            % Model Checks
            nInputCaseControl = size(obj,1);
            nModelSuperElements = size(model,1);
            nModelSuperElementID = size(modelSuperElementID,1);
            if nModelSuperElements~=nModelSuperElementID;
                error('Input inconsistent: nModelSuperElements~=nModelSuperElementID');
            end
            if modelSuperElementID(1)~=0; error('Residual structure should be first superement.'); end
            
            % % % PRECURSOR
            % % % The SUPER command can occur in each SUBCASE and can appear
            % % % before the first SUBCASE(in which case, it is a default).
            % % % This option is managed by the Case Entry class
            % % % entry2caseControl() method.
            %
            % % Set undefined superelement values to default. SUPER=ALL is 
            % % the default. However, if a SUPER command exists in the
            % % file, the default value for the SUPER command becomes 
            % % SUPER = 0, which is backward compatible with older version 
            % % of Nastran.
            if any([obj.superelement])
                defaultSuperelementID=int32(0);
            else
                defaultSuperelementID=int32(-1);
            end
            for i = 1:nInputCaseControl
                if isempty(obj(i).superelement)
                    obj(i).superelement=defaultSuperelementID;
                end
            end
            
            % Loop through CaseControl array to determine which Model
            % superelements apply. If a SET is referenced by 
            % obj(i).superelement, then the SET identification number 
            % must be unique with respect to any superelement 
            % identification numbers. In addition, the same sets must be 
            % used for all loading conditions.
            applicableSuperElementIndicies=cell(0);
            for i = 1:nInputCaseControl
                caseSuperelement = obj(i).superelement;
                if caseSuperelement==-1
                    applicableSuperElementIndicies{i,1}=uint32(1:nModelSuperElementID)';
                else
                    modelIndex = (caseSuperelement==modelSuperElementID);
                    if sum(modelIndex)>1; error('Model superelement uniqueness issue.'); end
                    if any(modelIndex)
                        % caseSuperelement is a superelement ID
                        applicableSuperElementIndicies{i,1}=uint32(find(modelIndex));
                    else
                        % caseSuperelement is (should be) a SET of superelement IDs
                        setIDs  = [obj(i).outputSet.ID];
                        setIndex = (caseSuperelement==setIDs);
                        if sum(setIndex)~=1;error('The should be one and only one SET with ID = %d in this subcase.',caseSuperelement); end
                        caseSuperElementIDs = obj(i).outputSet(setIndex).values();
                        [~,modelIndex2]=ismember(caseSuperElementIDs,modelSuperElementID);
                        if ~all(size(modelIndex2)==size(caseSuperElementIDs))
                            error('At least one superelement ID referenced by SET ID = %d was not found.',caseSuperelement);
                        end
                        applicableSuperElementIndicies{i,1}=uint32(modelIndex2);
                    end
                end
            end
            
            % Start with model(1), the residual structure, to determine the
            % number of load cases and load sequence
            for i = 1:nInputCaseControl
                if any(applicableSuperElementIndicies{i}==1)
                    model(1).caseControl=[model(1).caseControl;obj(i)];
                end
            end
            nLoadCases = size(model(1).caseControl,1);
            
            % Preallocate default case control values for remaining 
            % superelements for all load cases
            for i = 2:nModelSuperElements
                model(i).caseControl(nLoadCases,1) = CaseControl();
            end
            
            % Nested loop through remaining superelements and through the 
            % CaseControl array. Overwrite default CaseControl 
            % where specified
            for i = 2:nModelSuperElements
                loadSequenceID = 0;
                for j = 1:nInputCaseControl
                    if any(applicableSuperElementIndicies{j}==i)
                        if isempty(obj(j).loadSequence)
                            loadSequenceID = loadSequenceID + 1;
                        else
                            loadSequenceID = obj(j).loadSequence;
                        end
                        if ~isempty(model(i).caseControl(loadSequenceID).superelement)
                            error(['Superelement ID %d load sequence number',...
                                ' %d is defined more than once. Check case control inputs.'],modelSuperElementID(i),loadSequenceID);
                        end
                        model(i).caseControl(loadSequenceID) = obj(j);
                    end
                end
            end
        end % caseControl2model()
        
        function output(obj,fid)
            % Function to write subcase header
            fprintf(fid,'\n\n\n');
            fprintf(fid,[repmat('=',[1 104]),'\n']);
            fprintf(fid,[repmat(' ',[1 floor((104-17)/2)]),'S U B C A S E  %d\n'],obj.ID);
            fprintf(fid,[repmat(' ',[1 floor((104-size(obj.analysis,2))/2)]),'%s\n'],obj.analysis);
            fprintf(fid,[repmat('=',[1 104]),'\n']);
            fprintf(fid,'  %s\n',obj.title);
            fprintf(fid,'  %s\n',obj.subtitle);
            fprintf(fid,'  %s\n',obj.label);
        end
    end
    
end

function out = setInt(in,errStr)
if isnumeric(in)==0; error([errStr,' must be a number']); end
if mod(in,1) ~= 0; error([errStr,' must be an integer']); end
if in < 1; error([errStr,' must be greater than zero.']); end
out=uint32(in);
end