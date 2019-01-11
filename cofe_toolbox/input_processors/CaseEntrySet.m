% Class for SET Case Control entries
% Anthony Ricciardi
%
classdef CaseEntrySet < CaseEntry
    
    properties
        outputSet=OutputSet; % [OutputRequest]
    end
    methods
        function obj = CaseEntrySet(entryFields)
            % Process left-hand-side describers
            obj.outputSet.ID = castInputField('SET','LeftHandDescribers',entryFields.leftHandDescribers,'uint32',NaN,1);

            % Process right-hand-side describers
            if isempty(entryFields.rightHandDescribers)
                error('Missing right hand describers for SET Case Control entry.')
            else
                if strcmpi('ALL',strtrim(entryFields.rightHandDescribers))
                    obj.outputSet.all = true;
                else
                    splitRHS = strsplit(entryFields.rightHandDescribers,',');
                    nSet = size(splitRHS,2);
                    obj.outputSet.i1 = zeros(nSet,1,'uint32');
                    obj.outputSet.iN = zeros(nSet,1,'uint32');
                    obj.outputSet.thru = false(nSet,1);
                    for i=1:nSet
                        findThru = strfind(upper(splitRHS{i}),'THRU');
                        if isempty(findThru)
                            i1 = str2double(strtrim(splitRHS{i}));
                        else
                            splitField = strsplit(splitRHS{i});
                            if any([size(splitField,2)~=3,~strcmpi('THRU',splitField{2})])
                                error('There is an issue reading SET %d.',obj.outputSet.ID)
                            else
                                i1 = str2double(splitField{1});
                                obj.outputSet.iN(i) = setInt(str2double(splitField{3}),'SET input data');
                                obj.outputSet.thru(i) = true;
                            end
                        end
                        obj.outputSet.i1(i) = setInt(i1,'SET input data');
                    end
                end
            end
        end % CaseEntrySet()
        function caseControl = entry2caseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.outputSet = [caseControl.outputSet;obj.outputSet];
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            obj.outputSet.echo(fid)
        end
    end
end

function out = setInt(in,errStr)
if isnumeric(in)==0; error([errStr,' must be a number']); end
if mod(in,1) ~= 0; error([errStr,' must be an integer']); end
if in < 1; error([errStr,' must be greater than zero.']); end
out=uint32(in);
end