% Function to execute CoFE analysis
% Anthony Ricciardi
%
%  Inputs
%  inputFile  - [string] name of NASTRAN-formatted bulk data input file
%  CASE - [1x#subcases case_obj] array of objects containing case control data
%
% Output
% FEM - [1x#subcases fem] Array of finite element model and solution objects
%
function FEM = CoFE_analysis(inputFile,CASE)
if nargin < 2; error('Two input arguments required for CoFE_analysis()'); end

%% Instantiate FEM object and read model data from input file
FEM0 = importModel(inputFile);
FEM0.CASE = CASE;

%% Assemble array of subcases
FEM = assemble(FEM0,CASE);

%% Solve array of subcases
for sc = 1:size(FEM,2)
    switch FEM(sc).CASE.SOL
        case 101
            FEM(sc) = FEM(sc).analysis_101();
        case 103
            FEM(sc) = FEM(sc).analysis_103();
        case 105
            FEM(sc) = FEM(sc).analysis_105( FEM(FEM(sc).CASE.REF_LC) );
        otherwise
            error('FEM.CASE.SOL should be set to 101, 103, or 105.')
    end
end

%% Write output file
if FEM(1).CASE.PRINT
    % File extension
    ext = strfind(inputFile,'.bdf');
    if isempty(ext)
        ext = strfind(inputFile,'.dat');
        if isempty(ext) % can't find extension
            ext = length(inputFile)+1;
        end
    end
    outFile = [inputFile(1:ext-1),'.c06'];
    % Open file
    fid = fopen(outFile,'w');
    % Title Sheet
    titleString = legacy.titleSheet();
    for i = 1:size(titleString,1)
        fprintf(fid,[titleString{i},'\n']);
    end
    % fprintf(fid,[titleString{i},'\n']);
    fprintf(fid,'  This case was run %s \n',datestr(now));

    for sc = 1:size(FEM,2)
        FEM.write_c06(fid);
    end
end

