% Anthony Ricciardi
% Reads Nastran .pch file
%
% Inputs:
% InString - string that is the .pch file name
%
% Outputs:
% response - [ngrid x ndofs x ncases]
% frequencies [nmodes x 1]
function [response,frequencies,ev] = punchRead(InFile)

% InFile = 'l_static';

fid = fopen(strcat(InFile,'.pch'),'r');

% prenumber
frequencies=[];
ev=[];
%
%--------------------------------------------
% Read Section
%--------------------------------------------

output = textscan(fid, '%s');
nEntries = size(output{1,1},1);

DisSet = 0;
i = 0;
while i < nEntries
    i = i+1;
    outs = char( output{1,1}{i} );
    switch outs
        case {'$TITLE'} % New Set of Displacements
            DisSet = DisSet + 1;
            nn = 0;
        case {'$EIGENVALUE'} % New Set of Displacements
            ev(DisSet) = str2num(char( output{1,1}{i+2} ));
            frequencies(DisSet) = sqrt(ev(DisSet))/(2*pi);
        case {'G'} % New Set of Displacements
            nn = nn + 1;
            response(nn,1,DisSet) = str2num(char( output{1,1}{i-1} )); % node number
            response(nn,2,DisSet) = str2num(char( output{1,1}{i+1} )); % T1
            response(nn,3,DisSet) = str2num(char( output{1,1}{i+2} )); % T2
            response(nn,4,DisSet) = str2num(char( output{1,1}{i+3} )); % T3
            response(nn,5,DisSet) = str2num(char( output{1,1}{i+6} )); % R1
            response(nn,6,DisSet) = str2num(char( output{1,1}{i+7} )); % R2
            response(nn,7,DisSet) = str2num(char( output{1,1}{i+8} )); % R3
            i = i + 8;
        otherwise
    end
end
fclose('all');