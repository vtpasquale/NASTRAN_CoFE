function [] = CoFE_view(FEM)

%% Main figure
%       [left bottom width height]
maxSize=[.05,.05,.9,.85];
scale = .75;
f = figure('Visible','on','Units','normalized','Color',[1 1 1],'Position',[maxSize(1:2),scale*maxSize(3:4)]);

%% Create GUI Handles Object to Store GUI data
h = guihandles(f);
h.FEM = FEM;

%% Gui Design Inputs
designColor         = [1 1 1];
implimentColor      = [0.9400 0.9400 0.9400];
textBackgroundColor = designColor;
titleBackground = [0.7 0.7 0.7];
h.fs = 12; % font Size

%% Logo Axis
im=imread('CoFE.png');
normSize=[238,168]./238;
axes('position',[0,0,0.12*normSize]);
imshow(im);

%% Main Axis
axes('Units','normalized','Position',[.05 .15 .65 .8]);

%% Tabs
tgroup = uitabgroup('Parent',f,'Position',[.75 0 1 1]);
tab1 = uitab('Parent', tgroup, 'Title', 'Results');
tab2 = uitab('Parent', tgroup, 'Title', 'Options');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TAB 1 - Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBCASE Selection
subcase_text = uicontrol('Style','text','String','SUBCASE Selection:',...
    'Parent',tab1,...
    'HorizontalAlignment','left',...
    'FontSize',h.fs,...
    'FontWeight','bold',...
    'BackgroundColor',titleBackground,...
    'Units','normalized',...
    'Position',[.01,.95,.22,.03]);

% Create SUBCASE List
rm_id = 1; % response mode identification number
for sc = 1:size(FEM,2)
    switch FEM(sc).CASE.SOL
        case 101
            rm_list{rm_id} = sprintf(' %d - Linear Statics',sc);
            rm_key(rm_id,:) = [sc 1]; rm_id = rm_id + 1;
        case 103
            for m = 1:FEM(sc).ND;
                rm_list{rm_id} = sprintf(' %d - Vibration Mode %d, Freq. = %G Hz',sc,m,FEM(sc).fHz(m));
                rm_key(rm_id,:) = [sc m]; rm_id = rm_id + 1;
            end
        case 105
            for m = 1:FEM(sc).ND;
                rm_list{rm_id} = sprintf(' %d - Buckling Mode %d, EigVal. = %G ',sc,m,FEM(sc).eVal(m));
                rm_key(rm_id,:) = [sc m]; rm_id = rm_id + 1;
            end
        otherwise
            error('FEM.CASE.SOL should be 101, 103, or 105')
    end
end
h.rm_key = rm_key;
h.subcase = 1;
uicontrol('Parent',tab1, 'Style','listbox', ...
    'FontSize',h.fs,...
    'Callback',{@setSubcase},...
    'String',rm_list,...
    'Units','normalized',...
    'Value',1,...
    'Position',subcase_text.Position+[0 -.19 0 .15]);
%
% CONTOUR RESULT:
contour_text = uicontrol('Style','text','String','CONTOUR Selection:',...
    'Parent',tab1,...
    'HorizontalAlignment','left',...
    'FontSize',h.fs,...
    'FontWeight','bold',...
    'BackgroundColor',titleBackground,...
    'Units','normalized','Position',[subcase_text.Position(1) .70 subcase_text.Position(3) .03]);
h.contourLists = createContourList(FEM);
uicontrol('Parent', tab1, 'Style','listbox', ...
    'FontSize',h.fs,...
    'Callback',{@setContourType},...
    'Units','normalized',...
	'Value',1,...
    'Position',contour_text.Position+[0 -.19 0 .15],...
    'String',h.contourLists{h.subcase});
h.fopts.contourType = h.contourLists{h.subcase}{1};
%
% Contour Type Specific Options Text
h.uiContourTypeSpecificText = uicontrol('Style','text',...
    'String',' ',...
    'Parent',tab1,...
    'Visible','off',...
    'HorizontalAlignment','left',...
    'FontSize',h.fs,...
    'BackgroundColor',textBackgroundColor,...
    'Units','normalized','Position',[subcase_text.Position(1) .47 subcase_text.Position(3) .03]);
%
% Contour Type Specific Options Dropdown
h.fopts.contourTypeSpecificOpt = 'None';
h.uiContourTypeSpecificOpt = ...
    uicontrol('style','popup','Parent',tab1,...
    'FontSize',h.fs,...
    'Value',1,...
    'Visible','off',...
    'Units','normalized','Position',[subcase_text.Position(1) .43 subcase_text.Position(3) .03],...
    'String',{'Opt. 1','Opt. 2'},'Callback',{@setContourTypeSpecificOpt});
%
% Quadrilateral Options:
uicontrol('Style','text','String','Quadrilateral Options:',...
    'Parent',tab1,...
    'HorizontalAlignment','left',...
    'FontSize',h.fs,...
    'BackgroundColor',textBackgroundColor,...
    'Units','normalized','Position',[subcase_text.Position(1) .37 subcase_text.Position(3) .03]);
uicontrol('style','popup','Parent',tab1,...
    'FontSize',h.fs,...
    'Units','normalized','Position',[subcase_text.Position(1) .33 subcase_text.Position(3) .03],...
    'String',{'Opt. 1','Opt. 2','Opt. 3'},'Callback',{@quad_option});
%
% Beam Options:
uicontrol('Style','text','String','Beam Options:',...
    'Parent',tab1,...
    'HorizontalAlignment','left',...
    'FontSize',h.fs,...
    'BackgroundColor',textBackgroundColor,...
    'Units','normalized','Position',[subcase_text.Position(1) .27 subcase_text.Position(3) .03]);
uicontrol('style','popup','Parent',tab1,...
    'FontSize',h.fs,...
    'Units','normalized','Position',[subcase_text.Position(1) .23 subcase_text.Position(3) .03],...
    'String',{'Opt. 1','Opt. 2','Opt. 3'},'Callback',{@quad_option});
%
% Deformation Options
uicontrol('Style','text','String','DEFORMATION Options:',...
    'Parent',tab1,...
    'HorizontalAlignment','Left',...
    'FontSize',h.fs,...
    'FontWeight','bold',...
    'BackgroundColor',titleBackground,...
    'Units','normalized','Position',[subcase_text.Position(1) .17 subcase_text.Position(3) .03]);
%
% Undeformed Structure
h.undeformedVisibility = 'on';
uicontrol('style','checkbox','Parent',tab1,...
    'FontSize',h.fs,...
    'Units','normalized','Position',[subcase_text.Position(1) .135 .03 .02],...
    'Value',1,...
    'Callback',{@setUndeformedVisibility});
uicontrol('style','text','String','Show Undeformed Structure',...
    'Parent',tab1,'FontSize',h.fs,...
    'HorizontalAlignment','left',...
    'BackgroundColor',textBackgroundColor,...
    'Units','normalized',...
    'Position',[subcase_text.Position(1)+.015 .13 subcase_text.Position(3)-.015 .03]);
%
% Deformed Structure
h.deformedVisibility = 'on';
uicontrol('style','checkbox','Parent',tab1,...
    'FontSize',h.fs,...
    'Value',1,...
    'Units','normalized','Position',[subcase_text.Position(1) .095 .03 .02],...
    'Callback',{@setDeformedVisibility});
uicontrol('style','text','String','Show Deformed Structure',...
    'Parent',tab1,'FontSize',h.fs,...
    'HorizontalAlignment','left',...
    'BackgroundColor',textBackgroundColor,...
    'Units','normalized',...
    'Position',[subcase_text.Position(1)+.015 .09 subcase_text.Position(3)-.015 .03]);
%
% Scale Deformed Structure
h.uiScaleFactor = uicontrol('style','edit','Parent',tab1,...
    'FontSize',h.fs,...
    'Units','normalized','Position',[subcase_text.Position(1) .035 .06 .04],...
    'Callback',{@setDeformedScaleFactor});
uicontrol('style','text','String','Scale Factor',...
    'Parent',tab1,'FontSize',h.fs,...
    'HorizontalAlignment','left',...
    'BackgroundColor',textBackgroundColor,...
    'Units','normalized',...
    'Position',[subcase_text.Position(1)+.06 .04 subcase_text.Position(3)-.06 .03]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TAB 2 - Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% access colormap editor
uicontrol('Style', 'pushbutton', 'String', 'Open Colormap Editor',...
    'Parent',tab2,...
    'Units','normalized','Position',[.01,.9,.2,.05],...
    'Callback', 'colormapeditor');

% save figure button
uicontrol('Style', 'pushbutton', 'String', 'Save Figure as Image',...
    'Parent',tab2,...
    'Units','normalized','Position',[.01,.8,.2,.05],...
    'Callback', {@figureSave});

% line color options
h.lineRgbValues =[0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];

for i = 1:size(h.lineRgbValues,1);
    chooseColor{i} = sprintf('<HTML><font color="white" bgcolor="rgb(%f,%f,%f)">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</HTML>',255*h.lineRgbValues(i,:));
end
uicontrol('style','popup',...
    'Units','normalized','Position',[.01,.7,.2,.05],'Parent',tab2,...
    'String',chooseColor,'Callback',{@setUndLineRgb});
h.fopts.undLineRgb = h.lineRgbValues(1,:);

% Line width options
for i = 1:5;
    chooseLineWidth{i} = sprintf('<HTML><HR NOSHADE SIZE="%d" WIDTH="300"></HTML>',i);
end
h.fopts.undLineWidth = 2;
h.fopts.defLineWidth = 2;
uicontrol('style','popup',...
	'Value',h.fopts.undLineWidth,...
    'Units','normalized','Position',[.01,.65,.2,.05],'Parent',tab2,...
    'String',chooseLineWidth,'Callback',{@setLineWidth});

% Contour colormap options
h.colorMaps = {'Parula'
    'Jet'
    'HSV'
    'Hot'
    'Cool'
    'Spring'
    'Summer'
    'Autumn'
    'Winter'
    'Gray'
    'Bone'
    'Copper'
    'Pink'};
for i = 1:size(h.colorMaps,1);
    chooseColor{i} = ['<HTML>',sprintf('<font color="black" bgcolor="rgb(%f,%f,%f)">&nbsp;',255*colormap(h.colorMaps{i})'),'<font color="black" bgcolor="white">&nbsp;&nbsp;',h.colorMaps{i},'</HTML>',];
end
uicontrol('style','popup',...
    'Value',1,...
    'Units','normalized','Position',[.01,.6,.2,.05],'Parent',tab2,...
    'String',chooseColor,'Callback',{@setContourColorMap})
colormap(h.colorMaps{1});

%% Determine Model Size
h.model_size = max(max(FEM(1).gcoord,[],2)-min(FEM(1).gcoord,[],2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial Figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% store gui handles
guidata(f,h); 

%% Startup
plotSig(f);
% deformedVisibility();
% undeformedVisibility();
% colormap(colorMaps{1});
% setLineColor();
% setLineWidth();

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot function
function plotSig(source,eventdata,dontUpdateScaleFactor)

h = guidata(source);

% Pick subcase and mode number
FEMP = h.FEM(h.rm_key(h.subcase,1)); % select subcase
mode_number = h.rm_key(h.subcase,2);

% Response scaling
if nargin < 3
    max_def = max(abs( FEMP.u(:,mode_number) ));
    h.fopts.scaleFac = .15 * h.model_size/max_def;
    set(h.uiScaleFactor,'String',num2str(h.fopts.scaleFac));
end

% Subcase Mode
u_plot = FEMP.u(:,mode_number);

% Loop through plotList
cla
hold on
iter = 0;
for j = 1:size(FEMP.elementList,2)
    for i = 1:size(FEMP.(FEMP.elementList{j}),2)
        
        iter = iter + 1;
        h.und(iter) = plot(FEMP.(FEMP.elementList{j})(i),[],...
            'color',h.fopts.undLineRgb,...
            'linewidth',h.fopts.undLineWidth);
        
        h.def(iter) = contour(FEMP.(FEMP.elementList{j})(i),u_plot,mode_number,h.fopts); %
    end
end
xlabel('x')
ylabel('y')
zlabel('z')
axis('on')
hold off

display_text = uicontrol('style','text','String','SUBCASE 1 - Linear Statics',...
    'FontSize',h.fs+2,...
    'FontWeight','bold',...
    'HorizontalAlignment','center',...
    'BackgroundColor',[1 1 1],...
    'Units','normalized',...
    'Position',[.05 .95 .65 .04]);

% Apply visibilities
set(h.und,'Visible',h.undeformedVisibility);
set(h.def,'Visible',h.deformedVisibility);

% Save plot handles to guidata
guidata(source,h);

end

%% Contour List Function
function contourLists = createContourList(FEM)
nsc = size(FEM,2);
contourLists = cell(nsc,1);
for i = 1:nsc
    list{1} = 'None';
    list{2} = 'Displacements';
    list{3} = 'Rotations';
    ln = 4;
    if FEM(i).CASE.FORCE == 1
        list{ln} = 'Element Nodal Forces'; ln = ln + 1;
    end
    if FEM(i).CASE.STRESS == 1
        list{ln} = 'Stress'; ln = ln + 1;
    end
    if FEM(i).CASE.STRAIN == 1
        list{ln} = 'Strain'; ln = ln + 1;
    end
    if FEM(i).CASE.ESE == 1
        list{ln} = 'Element Strain Energy'; ln = ln + 1;
    end
    if FEM(i).CASE.EKE == 1
        list{ln} = 'Element Kinetic Energy';
    end
    contourLists{i}=list;
    clear list
end
end

%% Callbacks
function setSubcase(source,eventdata)
h = guidata(source);
h.subcase = h.rm_key(source.Value,1);
guidata(source,h);
plotSig(source,eventdata)
end
function setContourType(source,eventdata)

% Set New Contour Type
h = guidata(source);
h.fopts.contourType = h.contourLists{h.subcase}{source.Value};

% Provide Contour Type Specific Options
set(h.uiContourTypeSpecificOpt,'Visible','on');
set(h.uiContourTypeSpecificText,'Visible','on');
set(h.uiContourTypeSpecificText,'String',[h.fopts.contourType,' Contour Options']);
colorbar('Visible','on')
switch h.fopts.contourType
    case {'Displacements','Rotations','Element Nodal Forces'}
        set(h.uiContourTypeSpecificOpt,'String',...
            {'Magnitude','X Component','Y Component','Z Component'})
        set(h.uiContourTypeSpecificOpt,'Value',1)
        h.fopts.contourTypeSpecificOpt = 'Magnitude';
    case 'Stress'
    case 'Strain'
    case {'Element Strain Energy',...
          'Element Kinetic Energy',...
          'None'}
        set(h.uiContourTypeSpecificOpt,'Visible','off');
        set(h.uiContourTypeSpecificText,'Visible','off');
        colorbar('Visible','off')
    otherwise
        error([fopts.contourType, 'Contour type not supported'])
end

guidata(source,h);
plotSig(source,eventdata,'Use Existing Scale Factor')
end
function setContourTypeSpecificOpt(source,eventdata)
h = guidata(source);
h.fopts.contourTypeSpecificOpt = ...
    h.uiContourTypeSpecificOpt.String{h.uiContourTypeSpecificOpt.Value};
guidata(source,h);
plotSig(source,eventdata,'Use Existing Scale Factor')
end
function setUndeformedVisibility(source,eventdata)
h = guidata(source);
if source.Value
    h.undeformedVisibility = 'on';
else
    h.undeformedVisibility = 'off';
end
guidata(source,h);
set(h.und,'Visible',h.undeformedVisibility);
end
function setDeformedVisibility(source,eventdata)
h = guidata(source);
if source.Value
    h.deformedVisibility = 'on';
else
    h.deformedVisibility = 'off';
end
guidata(source,h);
set(h.def,'Visible',h.deformedVisibility);
end
function setUndLineRgb(source,eventdata)
h = guidata(source);
h.fopts.undLineRgb = h.lineRgbValues(source.Value,:);
guidata(source,h);
set(h.und,'Color',h.fopts.undLineRgb);
end
function setLineWidth(source,eventdata)
h = guidata(source);
h.fopts.undLineWidth = source.Value;
h.fopts.defLineWidth = source.Value;
set(h.und,'LineWidth',h.fopts.undLineWidth);
set(h.def,'LineWidth',h.fopts.defLineWidth);
guidata(source,h);
end
function setContourColorMap(source,eventdata)
h = guidata(source);
colormap(h.colorMaps{source.Value});
end
function setDeformedScaleFactor(source,eventdata)
h = guidata(source);
h.fopts.scaleFac = str2double(source.String);
guidata(source,h);
plotSig(source,eventdata,'Use Prescribed Scale Factor')
end
function figureSave(source,eventdata)
% DPI = 300; % Dots per square inch.  Higher dpi will give higher resolution
% set(f, 'PaperPositionMode','manual');
% set(f,'Units','inches')
% h=get(f,'Position');
% set(f, 'PaperPosition', [0,0,h(3),h(4)]);
% set(f, 'PaperSize', [.75*h(3), h(4)])
% print('-dpdf',strcat('-r',num2str(DPI)),'figSave')
% set(f,'Units','normalized')
end