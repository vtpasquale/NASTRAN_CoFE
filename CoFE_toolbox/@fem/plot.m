function plot(obj,figHand,varargin)
figure(figHand)
hold on

%% plot options
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

%% Set Scale Factor
if any(strcmp(varargin,'scaleFactor'))
    if sum(strcmp(varargin,'scaleFactor')) > 1
        error('Repeated scaleFactor arguments in plot function call.')
    end
    scaleFactor = varargin{find(any(strcmp(varargin,'scaleFactor')))+1};
else
    scaleTo = .25* max([max(obj.gcoord(1,:)) - min(obj.gcoord(1,:));
        max(obj.gcoord(2,:)) - min(obj.gcoord(2,:));
        max(obj.gcoord(3,:)) - min(obj.gcoord(3,:))]);
    scaleFactor = scaleTo./max(max(abs(obj.x(obj.gnum2gdof(1:3,:)))));
end
nasScaleFactor = scaleFactor;

%% If provided, reformat NASTRAN response data
if any(strcmp(varargin,'nastran'))
    nastran_response = varargin{find(strcmp(varargin,'nastran'))+1};
    dnas = nastran_response(:,1);
    snas = size(dnas,1);
    scof = size(obj.gnum,2);
    if snas ~= scof
        error('Specified NASTRAN response data has a differnt number of nodes than the FEM object')
    end
    nodeSrt = repmat(obj.gnum,[scof,1])==repmat(dnas,[1,snas]);
    if any(sum(nodeSrt)~=1)
        error('There is an issue with node number consistancy')
    end
    
    xnas = zeros(obj.ndof,1);
    for i = 1:obj.nnodes
        xnas(obj.gnum2gdof(:,i)) = nastran_response(nodeSrt(i,:),2:7)';
    end
end

%% sort out options
nLegend = 1;
if any(strcmp(varargin,'undeformed'))
    undeformed = true;
    legendStrings{nLegend} = 'Undeformed'; nLegend = nLegend + 1;
else
    undeformed = false;
end

if any(strcmp(varargin,'deformed'))
    deformed = true;
    legendStrings{nLegend} = 'CoFE'; nLegend = nLegend + 1;
    xdef = scaleFactor*obj.x;
else
    deformed = false;
end


if any(strcmp(varargin,'nastran'))
    nastran = true;
    legendStrings{nLegend} = 'MSC Nastran'; nLegend = nLegend + 1;
    xnasdef = nasScaleFactor*xnas;
else
    nastran = false;
end


%% Loop through elements
for j = 1:size(obj.elementList,2)
    for i = 1:size(obj.(obj.elementList{j}),2)
        
        if undeformed
            plot(obj.(obj.elementList{j})(i),[],undeformedStyle{:})
        end
        if deformed
            plot(obj.(obj.elementList{j})(i),xdef,deformedStyle{:})
        end
        if nastran
            plot(obj.(obj.elementList{j})(i),xnasdef,nastranStyle{:})
        end
    end
end

% %% CQUAD4
% for i = 1:size(obj.CQUAD4,2)
%     nodeNum = [obj.CQUAD4(i).G1,obj.CQUAD4(i).G2,obj.CQUAD4(i).G3,obj.CQUAD4(i).G4];
%     plot(obj.CQUAD4(i),scaleFactor*obj.x(obj.gnum2gdof(1:3,nodeNum)),'contour')
% end

%% figure
hold off
legend(legendStrings{:},'Location' ,'NorthEastOutside')
xywh = get(gcf, 'Position');
set(gcf,'Position', [xywh(1) xywh(2) 1.5*xywh(3) xywh(4)])
% axis equal


