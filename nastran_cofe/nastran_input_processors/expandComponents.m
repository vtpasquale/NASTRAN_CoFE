% Function to expand and check that component input is zero OR a sequential combination of the Integers 1 thru 6.
% Anthony Ricciardi
%
% Inputs: 
% c = [uint32] integer to expand and check.
% entryNameAndFieldName = [char] Entry name and field name. For error messages.
% zeroAllowed = [logical]
%
% Outputs:
% intOut = [:,1 uint32]
%
function intOut = expandComponents(c,entryNameAndFieldName,zeroAllowed)
intOut = uint32(str2num(num2str(c)'));
pass = true;
if any(intOut<0) || any(intOut>6)
    pass=false;
end
uniqueCheck=unique(intOut);
if size(uniqueCheck,1)~=size(intOut,1)
    pass=false;
elseif any(intOut~=uniqueCheck)
    pass=false;
end
if intOut(1) == 0
    if ~zeroAllowed
        pass=false;
    elseif size(intOut,1) > 1
        pass = false;
    end
end
if ~pass
    if zeroAllowed
        error('%s field is not zero OR a unique and sequential combination of the Integers 1 through 6.',entryNameAndFieldName)
    else
        error('%s field is not a unique and sequential combination of the Integers 1 through 6.',entryNameAndFieldName)
    end
end

