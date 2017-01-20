function varargout = user_interface(varargin)
% seg_interface MATLAB code for seg_interface.fig
%      seg_interface, by itself, creates a new seg_interface or raises the existing
%      singleton*.
%
%      H = interface_interface returns the handle to a new seg_interface or the handle to
%      the existing singleton*.
%
%      seg_interface('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in seg_interface.M with the given input arguments.
%
%      seg_interface('Property','Value',...) creates a new seg_interface or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before seg_interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to seg_interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help seg_interface

% Last Modified by GUIDE v2.5 20-Jan-2017 11:58:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seg_interface_OpeningFcn, ...
                   'gui_OutputFcn',  @seg_interface_OutputFcn, ...
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


% --- Executes just before seg_interface is made visible.
function seg_interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seg_interface (see VARARGIN)

% Choose default command line output for seg_interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes seg_interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% reset(handles.axes1);
% cla(handles.axes1);
set(gcf,'WindowButtonDownFcn',{@mouse_down});
set(gcf,'WindowButtonMotionFcn',{@mouse_move});
set(gcf,'WindowButtonUpFcn',{@mouse_up});
global glb_handles;
glb_handles = handles;

% --- Outputs from this function are returned to the command line.
function varargout = seg_interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Image;
[filename, pathname, filterindex] = uigetfile({'*.png';'*.jpg';'*.bmp'},'File Selector');
Image = imread(fullfile(pathname, filename));
popupmenu1_Callback(hObject, eventdata, handles);

% --- Executes on button press in pushbutton_seg.
function pushbutton_seg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Image;
global Seeds;
global Seg;
global bb_x0 bb_x1 bb_y0 bb_y1;
global bounding_box_state;
addpath('./Algorithms');
current_method = get(handles.popupmenu1,'Value');

% graph cut
if(current_method == 1) 
    if(sum(sum(Seeds==127))==0 || sum(sum(Seeds==255))==0)
        disp('scribbles not provided!');
        return;
    end
    graphcut = GMMGraphCutAlgorithm();
    Seg =graphcut.Segment(Image, Seeds);
% grab cut
else 
    [H, W, C] = size(Image);
    if(bounding_box_state ~=2 )
        disp('bounding box not provided!');
        return;
    end
    mask = zeros([H,W]);
    mask(bb_y0:bb_y1, bb_x0:bb_x1)=1;
    grabcut = GMMGrabCutAlgorithm();
    Seg =grabcut.Segment(Image, mask,Seeds);
end
ui_update();


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global Image;
global Seeds;
global Seg;
global bounding_box_state;
current_value = get(handles.popupmenu1, 'Value');
if(current_value == 1) % graph cut
    set(handles.radiobutton_bb, 'Visible','Off');
    set(handles.radiobutton_scrb, 'Value', 1.0);
else
    set(handles.radiobutton_bb, 'Visible','On');
    set(handles.radiobutton_bb, 'Value', 1.0);    
end
[H, W, C] = size(Image);
Seeds = uint8(zeros([H,W]));
Seg = uint8(zeros([H, W]));
bounding_box_state = 0;
ui_update();

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
