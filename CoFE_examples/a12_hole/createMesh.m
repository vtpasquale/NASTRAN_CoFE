% Scritp to create hole mesh
% Anthony Ricciardi
%
% Clear memory and set path
clearvars; clf; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% Geometry
r = .5; % hole radius
h = 3; % rectangle height
w = 6; % rectangle width

%% Mesh
n = 16;  % number of nodes between circle and boundary
ns = 7; % number of nodes on short side
nl = 21; % number of nodes on long side

%% Create mesh
pc = .5*[-w -h; w -h; w h; -w h] ;% corner points
ac = atan2(pc(:,2),pc(:,1)); % corner angles
ac(ac<0)=ac(ac<0)+2*pi; % make angles positive

%%

pre_node_nums = 0;
all_node_nums = [];
all_node_xval = [];
all_node_yval = [];
cquad4_g1 = [];
cquad4_g2 = [];
cquad4_g3 = [];
cquad4_g4 = [];

a = ac([3 4 1 2 3]); % point angles
p = pc([3 4 1 2 3],:); % corner points
for i = 1:4;
    if ( a(i+1)-a(i) ) < 0
        a(i) = a(i) - 2*pi;
    end
    if ( a(i+1)-a(i) ) > pi/2
        ni = nl;
    else
        ni = ns;
    end
    ti = linspace(a(i),a(i+1),ni);
    p1 = r*[cos(ti)' sin(ti)'];
    p2 = [linspace(p(i,1),p(i+1,1),ni)',linspace(p(i,2),p(i+1,2),ni)'];
    for s = 1:ni
        xval = linspace(p1(s,1),p2(s,1),n);
        yval = linspace(p1(s,2),p2(s,2),n);
        node_nums = pre_node_nums(end)+1:pre_node_nums(end)+n;     
        
        % CQUAD4 nodes numbers
        if s ~= 1
            cquad4_g1 = [cquad4_g1, pre_node_nums(1:1:end-1)];
            cquad4_g2 = [cquad4_g2, pre_node_nums(2:1:end)];
            
            if s == ni && i == 4
                cquad4_g4 = [cquad4_g4, node_nums_1(1:1:end-1)];
                cquad4_g3 = [cquad4_g3, node_nums_1(2:1:end)];
            else
                cquad4_g4 = [cquad4_g4, node_nums(1:1:end-1)];
                cquad4_g3 = [cquad4_g3, node_nums(2:1:end)];
            end
        end
        
        
        % Save, but not last set in each quandrant
        if s ~= ni
            pre_node_nums = node_nums;
            all_node_nums = [all_node_nums, node_nums];
            all_node_xval = [all_node_xval,xval];
            all_node_yval = [all_node_yval,yval];
        end
        
        % Save intial node numbers
        if s == 1 && i == 1
            node_nums_1 = node_nums;
        end
        
    end
end

%% Plot
figure(1)
hold on

plot(all_node_xval,all_node_yval,'o')
for i = 1:size(cquad4_g1,2)
    plot(all_node_xval([cquad4_g1(i),cquad4_g2(i),cquad4_g3(i),cquad4_g4(i),cquad4_g1(i)]),all_node_yval([cquad4_g1(i),cquad4_g2(i),cquad4_g3(i),cquad4_g4(i),cquad4_g1(i)]),'b-')
end
hold off
axis equal

% figure(2)
% hold on
% plot(all_node_xval,all_node_yval,'.')
% text(all_node_xval,all_node_yval,num2str(all_node_nums'))
% hold off

%% write to file
fid = fopen('mesh.bdf','w');
% fid = 1;

% print all nodes
fprintf(fid,'GRID,%d,,%f,%f,0.,,3456\n',[all_node_nums;all_node_xval;all_node_yval]);

% print all CQUAD4s
fprintf(fid,'CQUAD4,%d,101,%d,%d,%d,%d\n',[1:size(cquad4_g1,2);cquad4_g1;cquad4_g2;cquad4_g3;cquad4_g4]);

% print a pshell
fprintf(fid,'PSHELL,101,501,0.0833\n');

% print a mat1
fprintf(fid,'MAT1,501,1440000000.0,,0.33,5.370788\n');

% print boundary conditions
fprintf(fid,'SPC1,1,12,%d\n',all_node_nums(all_node_xval==-w/2));

% print loads 
fprintf(fid,'FORCE,1,%d,,1.0E6,1.0,0,0\n',all_node_nums(all_node_xval==w/2 & abs(all_node_yval) ~= h/2));
fprintf(fid,'FORCE,1,%d,,0.5E6,1.0,0,0\n',all_node_nums(all_node_xval==w/2 & abs(all_node_yval) == h/2));


fclose('all');
