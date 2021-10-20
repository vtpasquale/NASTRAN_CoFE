clearvars; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));

N = 10:10:80;

for i = 1:size(N,2)
    n = N(i);

    tic
    A1b = wathen1b(n,n) ;
    noTriplets(i) = toc;
    sizeA(i) = size(A1b,1);
    
    tic
    A2 = wathen2(n,n) ;
    simpleTime(i) = toc;
    disp (norm (A1b-A2,1))
    
    tic
    AF = wathenFunctionUpdate(n,n) ;
    functionTime(i) = toc;
    disp (norm (A2-AF,1))
    
    tic
    ACH = wathenSparseTripletHandle(n,n);
    classHandleTime(i) = toc;
    disp (norm (A2-ACH,1))
    
    tic
    ACV = wathenSparseTripletValue(n,n);
    classValueTime(i) = toc;
    disp (norm (A2-ACV,1))
end

figure(1)
loglog(sizeA,[simpleTime;functionTime;classHandleTime;classValueTime;noTriplets]','.-')
legend('Triplets Bare Bones','Triplets Function','Triplets Handle Class','Triplets Value Class','Without Triplets','location','northwest')
grid on
xlabel('Matrix Size')
ylabel('Assembly Time (s)')
xlim([.5*sizeA(1),2*sizeA(end)])
% fprintf('Triplets Bare Bones:  %8.4f sec\n',simpleTime)
% fprintf('Triplets Function:    %8.4f sec\n',functionTime)
% fprintf('Triplets Handle Class:%8.4f sec\n',classHandleTime)
% fprintf('Triplets Value Class: %8.4f sec\n',classValueTime)
% fprintf('Without Triplets:     %8.4f sec\n',noTriplets)

figure(2)
loglog(sizeA,classValueTime./classHandleTime,'.-')
grid on
xlabel('Matrix Size')
ylabel('Assembly Time Fraction')
title('Value Class Runtime/Handle Class Runtime')
xlim([.5*sizeA(1),2*sizeA(end)])

figure(3)
loglog(sizeA,noTriplets./classHandleTime,'.-')
grid on
xlabel('Matrix Size')
ylabel('Assembly Time Fraction')
title('Without Triplets/Triplets Value Class Runtime')
xlim([.5*sizeA(1),2*sizeA(end)])