function varargout = post_gui(varargin)
% POST_GUI MATLAB code for post_gui.fig
%      POST_GUI, by itself, creates a new POST_GUI or raises the existing
%      singleton*.
%
%      H = POST_GUI returns the handle to a new POST_GUI or the handle to
%      the existing singleton*.
%
%      POST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POST_GUI.M with the given input arguments.
%
%      POST_GUI('Property','Value',...) creates a new POST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before post_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to post_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help post_gui

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @post_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @post_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before post_gui is made visible.
function post_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to post_gui (see VARARGIN)

% Choose default command line output for post_gui
handles.output = hObject;

% UIWAIT makes post_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% Plot Logo
axis(handles.axes9)
image(imread('CoFE.png'));
axis image
axis off

%% Process varargin
% CoFE model and Results
handles.FEM = varargin{1};
handles.FEMxplot = [handles.FEM.u];
isemptyFEMu = isempty(handles.FEMxplot);

%% Checkboxes and legend
set(handles.checkbox1,'Value',1)
if isemptyFEMu && size(varargin,2) < 2
    % preprocess only
    set(handles.checkbox1,'Visible','off')
else
    set(handles.checkbox1,'String','Show Undeformed')
end

if isemptyFEMu
    % no CoFE results
    set(handles.checkbox2,'Visible','off')
else
    set(handles.checkbox2,'Value',1)
    set(handles.checkbox2,'String','Show CoFE Result')
end

if size(varargin,2) > 1
    set(handles.checkbox3,'Value',1)
    set(handles.checkbox3,'String','Show MSC Nastran Result')
else
    set(handles.checkbox3,'Visible','off')
end
updateLengend(handles) 

%% CoFE List
if isemptyFEMu == 0
    set(handles.text6,'String','CoFE Results')
    j = 1;
    for sc =1:size(handles.FEM,2)
        switch handles.FEM(sc).CASE.SOL
            case 101
                list1{j} = 'Linear Static'; j = j + 1;
            case 103
                for i = 1:size(handles.FEM(sc).u,2)
                    list1{j} = sprintf('Vibration Mode %d: %.4f Hz',i,handles.FEM(sc).fHz(i)); j = j + 1;
                end
            case 105
                for i = 1:size(handles.FEM(sc).u,2)
                    list1{j} = sprintf('Buckling Mode %d: ev = %.4f',i,handles.FEM(sc).eVal(i)); j = j + 1;
                end
        end
    end
    if j == 1;
        list1{2} = '';
    end
    set(handles.listbox1,'String',list1)
    set(handles.listbox1,'Value',1)
else
    set(handles.listbox1,'Visible','off')
    set(handles.text6,'String','')
    set(handles.edit1,'Visible','off')
    set(handles.text11,'String','')
end

%% NASTRAN List
if size(varargin,2) > 1
    set(handles.text7,'String','MSC Nastran Results')
    list2 = varargin{3};
    if size(list2,2) == 1;
        list2{2} = '';
    end
    set(handles.listbox2,'String',list2)
    set(handles.listbox2,'Value',1)
else
    set(handles.listbox2,'Visible','off')
    set(handles.text7,'String','')
    
    set(handles.edit2,'Visible','off')
    set(handles.text12,'String','')
end

%% combine results for plotting
    
if size(varargin,2) > 1
    handles.nas_response = varargin{2};
else
    handles.nas_response = [];
end

if size(varargin,2) > 3
    handles.nas_scaleOption = varargin{4};
elseif size(varargin,2) > 1
    handles.nas_scaleOption = 2*ones(size(varargin{2},3));
else
    handles.nas_scaleOption = [];
end

%% Scales
handles=updateScales(handles);

%% Update handles structure
guidata(hObject, handles);

%% plot default results
updatePlot(handles)
% Hints: contents = cellstr(get(handles.listbox1,'String')) returns listbox2 contents as cell array
%        contents{get(handles.listbox1,'Value')} returns selected item from listbox2


% --- Outputs from this function are returned to the command line.
function varargout = post_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
handles=updateScales(handles);
updatePlot(handles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
handles=updateScales(handles);
updatePlot(handles)

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
updatePlot(handles)

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
updatePlot(handles)

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
updatePlot(handles)

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.CoFE_scaleFactor = str2double(get(hObject,'String'));
guidata(hObject,handles);
updatePlot(handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.nas_scaleFactor =  str2double(get(hObject,'String'));
guidata(hObject,handles);
updatePlot(handles);


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% 
function updatePlot(handles)
updateLengend(handles) 

axes(handles.axes1)
cla

if get(handles.checkbox1,'Value')
    undeformed = 1;
else
    undeformed = 0;
end

if get(handles.checkbox2,'Value')
    xplot = handles.FEMxplot(:,get(handles.listbox1,'Value'));
else
    xplot = [];
end

if get(handles.checkbox3,'Value')
    nas_response = handles.nas_response(:,:,get(handles.listbox2,'Value'));
else
    nas_response = [];
end

post.plotMesh(handles.FEM(1),xplot,nas_response,handles.CoFE_scaleFactor,handles.nas_scaleFactor,handles.figure1,undeformed)



%%
function updateLengend(handles) 
% formatting
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

% top
axes(handles.axes2)
cla
if get(handles.checkbox1,'Value')
    plot([0 .5 1],[0 0 0],undeformedStyle{:})
    set(handles.text1,'String','Undeformed')
else
    set(handles.text1,'String','')
end
axis off

% middle
axes(handles.axes3)
cla
if get(handles.checkbox2,'Value')
    plot([0 .5 1],[0 0 0],deformedStyle{:})
    set(handles.text2,'String','CoFE')
else
    set(handles.text2,'String','')
end
axis off

% bottom
axes(handles.axes4)
cla
if get(handles.checkbox3,'Value')
    plot([0 .5 1],[0 0 0],nastranStyle{:})
    set(handles.text3,'String','MSC Nastran')
else
    set(handles.text3,'String','')
end
axis off


%%
function handles=updateScales(handles)

model_size = max(max(handles.FEM(1).gcoord,[],2)-min(handles.FEM(1).gcoord,[],2));

if get(handles.checkbox2,'Value')
    max_def = max(abs(  handles.FEMxplot(:,get(handles.listbox1,'Value'))  ));
    handles.CoFE_scaleFactor = .15 * model_size/max_def;  
    
    set(handles.edit1,'String',num2str(handles.CoFE_scaleFactor))
else
    handles.CoFE_scaleFactor = [];
end

if get(handles.checkbox3,'Value')  
    if handles.nas_scaleOption(get(handles.listbox2,'Value')) == 1 || isempty(handles.CoFE_scaleFactor)
        max_def_nas = max(max(abs(  handles.nas_response(:,2:7,get(handles.listbox2,'Value')) )));
        handles.nas_scaleFactor = .15 * model_size/max_def_nas;
    else
        handles.nas_scaleFactor = handles.CoFE_scaleFactor;
    end
    set(handles.edit2,'String',num2str(handles.nas_scaleFactor))
else
    handles.nas_scaleFactor = [];
end

