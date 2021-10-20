clearvars; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));
n = 80;

tic
A1b = wathen1b(n,n) ;
noTriplets = toc;

tic
A2 = wathen2(n,n) ;
simpleTime = toc;
% disp (norm (A1b-A2,1))

tic
AF = wathenFunctionUpdate(n,n) ;
functionTime = toc;
disp (norm (A2-AF,1))

tic
ACH = wathenSparseTripletHandle(n,n);
classHandleTime = toc;
disp (norm (A2-ACH,1))

tic
ACV = wathenSparseTripletValue(n,n);
classValueTime = toc;
disp (norm (A2-ACV,1))

fprintf('Triplets Bare Bones:  %8.4f sec\n',simpleTime)
fprintf('Triplets Function:    %8.4f sec\n',functionTime)
fprintf('Triplets Handle Class:%8.4f sec\n',classHandleTime)
fprintf('Triplets Value Class: %8.4f sec\n',classValueTime)
fprintf('Without Triplets:     %8.4f sec\n',noTriplets)


% classValueTime/classHandleTime
% classHandleTime/functionTime