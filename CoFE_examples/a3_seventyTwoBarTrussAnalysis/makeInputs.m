clear all; close all; clc

%% member number to property number (design variable number)
mem_2_prop  = ones(72,1);
mem_2_prop(1:4) = 1;
mem_2_prop(5:12) = 2;
mem_2_prop(13:16) = 3;
mem_2_prop(17:18) = 4;
mem_2_prop(19:22) = 5;
mem_2_prop(23:30) = 6;
mem_2_prop(31:34) = 7;
mem_2_prop(35:36) = 8;
mem_2_prop(37:40) = 9;
mem_2_prop(41:48) = 10;
mem_2_prop(49:52) = 11;
mem_2_prop(53:54) = 12;
mem_2_prop(55:58) = 13;
mem_2_prop(59:66) = 14;
mem_2_prop(67:70) = 15;
mem_2_prop(71:72) = 16;

%%
b = 60;
fid = fopen('seventyTwoBarTruss.bdf','w');

for Level = 1:5
    z = 4*b -(Level-1)*b;
    nn = (Level-1)*4;
    nnn= (Level  )*4;
    rn = (Level-1)*18;
    rnn= (Level  )*18; 
    
    fprintf(fid,'GRID,%d,,%f,%f,%f\n',nn+1,0,0,z);
    fprintf(fid,'GRID,%d,,%f,%f,%f\n',nn+2,2*b,0,z);
    fprintf(fid,'GRID,%d,,%f,%f,%f\n',nn+3,2*b,2*b,z);
    fprintf(fid,'GRID,%d,,%f,%f,%f\n',nn+4,0,2*b,z);
    
    if Level < 5
        % vertical rods
        for i = 1:4
            fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+i,mem_2_prop(rn+i),nn+i,nnn+i);
        end
        
        % diagonal rods
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+5,mem_2_prop(rn+5),nnn+1,nn+2);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+6,mem_2_prop(rn+6),nn+1,nnn+2);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+7,mem_2_prop(rn+7),nnn+2,nn+3);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+8,mem_2_prop(rn+8),nn+2,nnn+3);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+9,mem_2_prop(rn+9),nnn+3,nn+4);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+10,mem_2_prop(rn+10),nn+3,nnn+4);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+11,mem_2_prop(rn+11),nnn+4,nn+1);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+12,mem_2_prop(rn+12),nn+4,nnn+1);
        
        % horozontal rods
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+13,mem_2_prop(rn+13),nn+1,nn+2);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+14,mem_2_prop(rn+14),nn+2,nn+3);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+15,mem_2_prop(rn+15),nn+3,nn+4);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+16,mem_2_prop(rn+16),nn+4,nn+1);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+17,mem_2_prop(rn+17),nn+1,nn+3);
        fprintf(fid,'CROD,%d,%d,%d,%d\n',rn+18,mem_2_prop(rn+18),nn+2,nn+4);
    end
    
end

%% lumped masses for vibration problem
% node 1-4
fprintf(fid,'PMASS,100,12.95\n');
for i = 1:4
    fprintf(fid,'CMASS1,%d,100,%d,1\n',i*100+1,i);
    fprintf(fid,'CMASS1,%d,100,%d,1\n',i*100+2,i);
    fprintf(fid,'CMASS1,%d,100,%d,1\n',i*100+3,i);
end

%% Properties
for i = 1:16
    fprintf(fid,'PROD,%d,%d,%f,%f\n',i,101,.5,999);
end

%% Material
fprintf(fid,'MAT1,101,1.0E7,,.33,0.000259,\n');

%% Loads
fprintf(fid,'FORCE,1,1,,1.0,5000.0,5000.0,-5000.0\n');

fprintf(fid,'FORCE,2,1,,1.0,0.0,0.0,-5000.0\n');
fprintf(fid,'FORCE,2,2,,1.0,0.0,0.0,-5000.0\n');
fprintf(fid,'FORCE,2,3,,1.0,0.0,0.0,-5000.0\n');
fprintf(fid,'FORCE,2,4,,1.0,0.0,0.0,-5000.0\n');
% fprintf(fid,'FORCE,2,5,,1.0,0.0,20000.0,-5000.0\n');
% fprintf(fid,'FORCE,2,6,,1.0,0.0,-20000.0,-5000.0\n');

%% Boundary Conditions
% supports
fprintf(fid,'SPC1,1,123,%d\n',17);
fprintf(fid,'SPC1,1,123,%d\n',18);
fprintf(fid,'SPC1,1,123,%d\n',19);
fprintf(fid,'SPC1,1,123,%d\n',20);

%all rotations
for i = 1:20
    fprintf(fid,'SPC1,1,456,%d\n',i);
end

%% Comment Lines
fprintf(fid,'$\n$\n$\n$\n$\n$\n$\n$\n$\n$\n$\n$\n');

fclose('all')