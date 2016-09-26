% Function to plot unreformed and deformed mesh, and optionally compare to Nastran deformed mesh.
% Anthony Ricciardi
%
% Inputs
% FEM [Cell Structured Data] finite element model data
% x = solution vector for deformed mesh   (optional)
% nastran_response = selected Nastran solution output (optional)
% scaleOption [optional]
%           = 0 The actual response is scaled by a fraction (scaleFraction)
%   Default = 1 The CoFE and optional Nastran deformations are 
%               scaled by the same factor.  The scale factor is selected 
%               so that the maximum CoFE deformation is a fraction 
%               (scaleFraction) of the total unreformed model size.  This
%               is a good option for validating static response.
%           = 2 The CoFE and optional Nastran deformations are 
%               scaled independently.  The scale factor is selected 
%               so that the maximum deformations of both are a fraction 
%               (scaleFraction) of the total undeformed model size.  This
%               is a good option for validating eigenvector responses. 
% scaleFraction [optional]
%        Usage depends on scaleOption.  See scaleOption for details.
%        scaleOption = 0 -> Default = 1
%        scaleOption = 1,2 -> Default = 0.15
% undeformed [optional]
%        True -> plot undeformed mesh.  Default.
%        False -> plot deformed mesh
% 
% figNumber = Optional integer for figure number. Default = 1
% figTitle = Optional string for figure title. Default = ''
%
% Outputs
% void
%
function [] = plotMesh(FEM,x,nastran_response,CoFE_scaleFactor,nas_scaleFactor,figNumber,undeformed)
%% Check inputs
if nargin < 2 || isempty(x)
    x = [];
    deformed = 0;
end
if nargin < 3 || isempty(nastran_response)
    nastran_response = [];
    nastran = 0;
end

if nargin < 6 || isempty(figNumber)
    figNumber = 1;
end
if nargin < 7 || isempty(undeformed)
    undeformed = 1;
end

%% Plot options
% CC = linspecer(3,'qualitative'); % need plottoolbox
CC(1,:) = [1 0 0 ]; % red
CC(2,:) = [.3608 .251 .2]; % dark brown 
CC(3,:) = [0 1 1]; % cyan
marker1 = 'o';
marker2 = '.';
marker3 = 'none';
LineStyle1 = '-.';
LineStyle2 = '--';
LineStyle3 = '-';
LineWidth1 = 2;
LineWidth2 = 2;
LineWidth3 = 2;
nastranStyle = {'color',CC(1,:),'LineStyle',LineStyle1,'Marker',marker1,'LineWidth',LineWidth1};
undeformedStyle = {'color',CC(3,:),'LineStyle',LineStyle3,'Marker',marker3,'LineWidth',LineWidth3};
deformedStyle = {'color',CC(2,:),'LineStyle',LineStyle2,'Marker',marker2,'LineWidth',LineWidth2};

set(0,'defaultaxesfontsize',14);
set(0,'defaulttextfontsize',14);

%% if CoFE solution is included
if isempty(x) == 0
    deformed = 1;
    
    % Deformed mesh nodes
    x_scaled = CoFE_scaleFactor * x;
end

%% if Nastran solution is included
if isempty(nastran_response) == 0
    nastran = 1;
    
    %reformat NASTRAN response data
    dnas = nastran_response(:,1);
    snas = size(dnas,1);
    scof = size(FEM.gnum,2);
    if snas ~= scof
        error('Specified NASTRAN response data has a differnt number of nodes than the FEM object')
    end
    nodeSrt = repmat(FEM.gnum,[scof,1])==repmat(dnas,[1,snas]);
    if any(sum(nodeSrt)~=1)
        error('There is an issue with node number consistancy')
    end
    
    xnas = zeros(FEM.ndof,1);
    for i = 1:FEM.nnodes
        xnas(FEM.gnum2gdof(:,i)) = nastran_response(nodeSrt(:,i),2:7)';
    end
    
    % scaling
    xnas_scaled = nas_scaleFactor * xnas;
end

%% Plotting
figure(figNumber)
hold on
% Loop through plotList
for j = 1:size(FEM.plot0DList,2)
    for i = 1:size(FEM.(FEM.plot0DList{j}),2)
        
        if undeformed
            plot(FEM.(FEM.plot0DList{j})(i),[],undeformedStyle{:});
        end
        if deformed
            plot(FEM.(FEM.plot0DList{j})(i),x_scaled,deformedStyle{:});
        end
        if nastran
            plot(FEM.(FEM.plot0DList{j})(i),xnas_scaled,nastranStyle{:});
        end
    end
end
for j = 1:size(FEM.plot1DList,2)
    for i = 1:size(FEM.(FEM.plot1DList{j}),2)
        
        if undeformed
            plot(FEM.(FEM.plot1DList{j})(i),[],undeformedStyle{:});
        end
        if deformed
            plot(FEM.(FEM.plot1DList{j})(i),x_scaled,deformedStyle{:});
        end
        if nastran
            plot(FEM.(FEM.plot1DList{j})(i),xnas_scaled,nastranStyle{:});
        end
    end
end
for j = 1:size(FEM.plot2DList,2)
    for i = 1:size(FEM.(FEM.plot2DList{j}),2)
        
        if undeformed
            plot(FEM.(FEM.plot2DList{j})(i),[],undeformedStyle{:});
        end
        if deformed
            plot(FEM.(FEM.plot2DList{j})(i),x_scaled,deformedStyle{:});
        end
        if nastran
            plot(FEM.(FEM.plot2DList{j})(i),xnas_scaled,nastranStyle{:});
        end
    end
end
xlabel('x')
ylabel('y')
zlabel('z')
hold off
