% Function to check that an integer input field has a unique and sequential combination of the Integers 1 through 6.
% Anthony Ricciardi
%
% Inputs: C = [int] integer to check.
% entryName = [str] Name of input entry being checked. For error messages.
% idName = [str] Type of ID number used for input entry being checked. For error messages.
% idNumber = [int] ID number of input entry being checked. For error messages.
% fieldName = [str] Name of input field being checked. For error messages.
%
% Outputs: None. Throws an error if the integer fails the criteria
%
function [] = check_int1thru6(C,entryName,idName,idNumber,fieldName)
check = str2num(num2str(C)');
pass = true;
if any(check<1) || any(check>6)
    pass=false;
end
uniqueCheck=unique(check);
if size(uniqueCheck,1)~=size(check,1)
    pass=false;
elseif any(check~=uniqueCheck)
    pass=false;
end
if ~pass
    error('%s %s = %d field %s must have a unique and sequential combination of the Integers 1 through 6.',entryName,idName,idNumber,fieldName)
end

