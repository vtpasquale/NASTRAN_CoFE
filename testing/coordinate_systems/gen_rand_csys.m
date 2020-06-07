clear all; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

% random id number
cids = int32(randi([1,10000],100,1));
cids = unique(cids,'stable');
n = size(cids,1);

% random type
rcs = randi([1,3],n,1); % rectangular, cylindrical, sphereical

% random ref cid
rid = int32(zeros(n,1));
defined = int32(0);
undefined = cids;
undefinedINDEX = 1:n;
for i = 1:n
    ind = randi([1,n-i+1]);
    refINDEX = randi([1,i]);
    
    rid(undefinedINDEX(ind))=defined(refINDEX);
    defined=[defined;cids(undefinedINDEX(ind))];
    undefinedINDEX=undefinedINDEX((1:(n-i+1))~=ind);
end

% create coordinate system entries
for i = 1:n
    switch rcs(i)
        case 1
            c(i,1) = cord2r;
        case 2
            c(i,1) = cord2c;
        case 3
            c(i,1) = cord2s;
        otherwise
            error('wrong type')
    end
    if rid(i)==0
        refType=1;
    else
        refType = rcs(find(rid(i)==cids));
    end
    switch refType
        case 1
            a  = 100*(rand(3,1)-.5);
            b  = 100*(rand(3,1)-.5);
            cc = 100*(rand(3,1)-.5);
        case 2
            mt =[100*(rand(1,3)-.5);
                 360*(rand(1,3)-.5);
                 100*(rand(1,3)-.5)];
             a=mt(:,1);
             b=mt(:,2);
             cc=mt(:,3);
        case 3
            mt =[100*(rand(1,3)-.5);
                 360*(rand(1,3)-.5);
                 180* rand(1,3)];
             a=mt(:,1);
             b=mt(:,2);
             cc=mt(:,3);
        otherwise
            error('wrong type')
    end
    c(i).CID=cids(i);
    c(i).RID=rid(i);
    c(i).A=a;
    c(i).B=b;
    c(i).C=cc;
end

%% random nodes
nids = int32(randi([1,10000],100,1));
nids = unique(nids);
nnodes = size(nids,1);

for i = 1:nnodes
    c(i+n,1) = grid_obj;
    c(i+n).ID = nids(i);
    refINDEX = randi([1,n],1);
    c(i+n).CP=cids(refINDEX);
    c(i+n).CD=cids(randi([1,n],1));
    refType = rcs(refINDEX);
    switch refType
        case 1
            X_P  = 100*(rand(3,1)-.5);
        case 2
            X_P =[100*(rand(1,1)-.5);
                 360*(rand(1,1)-.5);
                 100*(rand(1,1)-.5)];
        case 3
            X_P =[100*(rand(1,1)-.5);
                 360*(rand(1,1)-.5);
                 180* rand(1,1)];
        otherwise
            error('wrong type')
    end
    c(i+n).X1=X_P(1);
    c(i+n).X2=X_P(2);
    c(i+n).X3=X_P(3);
end


%%
c.echo_all(1)

%%
m=c.entry2model_all()

%%
m=m.preprocess()

% % 
% % %% Read in data
% % i = 1;
% % c(i,1) = cord2r;
% % c(i) = c(i).initialize({'CORD2R',num2str(i),num2str(3),'-2.9','1.0','0.0','3.6','0.0','1.0','','','5.2','1.0','-2.9'});
% % 
% % i = 2;
% % c(i,1) = cord2c;
% % c(i) = c(i).initialize({'CORD2C',num2str(i),num2str(1),'-2.9','1.0','0.0','3.6','0.0','1.0','','','5.2','1.0','-2.9'});
% % 
% % i = 3;
% % c(i,1) = cord2s;
% % c(i) = c(i).initialize({'CORD2S',num2str(i),num2str(0),'-2.9','1.0','0.0','3.6','0.0','1.0','','','5.2','1.0','-2.9'});
% % 
% % c = c.prep();

%     
%     c(i).CID = i;
%     c(i).RID = 0;
%     c(i).XC_0 = 100*(rand(3,1)-.5);
%     
%     a = 180*(rand(3,1)-.5);
%     c(i).TC_C0 = [1         , 0         , 0
%         0         , cosd(a(1)), sind(a(1)); % R1
%         0         ,-sind(a(1)), cosd(a(1))]...
%         *[cosd(a(2)), 0         ,-sind(a(2)); % R2
%         0         , 1         , 0
%         sind(a(2)), 0         , cosd(a(2))] ...
%         *[cosd(a(3)), sind(a(3)), 0           % R3
%         -sind(a(3)), cosd(a(3)), 0
%         0        , 0         , 1         ];
%     
%     
%     %
%     XP_C = [1;180;360].*[rand(1);rand(1);rand(1)-.5];
%     XP_0 = c(i).XP_0(XP_C);
%     XP_C2 = c(i).XP_C(XP_0);
%     
%     [XP_0,XP_C,XP_C2]