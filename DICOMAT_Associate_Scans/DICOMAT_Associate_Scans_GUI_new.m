function varargout = DICOMAT_Associate_Scans_GUI(varargin)
% DICOMAT_ASSOCIATE_SCANS_GUI MATLAB code for DICOMAT_Associate_Scans_GUI.fig
%      DICOMAT_ASSOCIATE_SCANS_GUI, by itself, creates a new DICOMAT_ASSOCIATE_SCANS_GUI or raises the existing
%      singleton*.
%
%      H = DICOMAT_ASSOCIATE_SCANS_GUI returns the handle to a new DICOMAT_ASSOCIATE_SCANS_GUI or the handle to
%      the existing singleton*.
%
%      DICOMAT_ASSOCIATE_SCANS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DICOMAT_ASSOCIATE_SCANS_GUI.M with the given input arguments.
%
%      DICOMAT_ASSOCIATE_SCANS_GUI('Property','Value',...) creates a new DICOMAT_ASSOCIATE_SCANS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DICOMAT_Associate_Scans_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DICOMAT_Associate_Scans_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DICOMAT_Associate_Scans_GUI

% Last Modified by GUIDE v2.5 26-Jan-2011 22:41:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DICOMAT_Associate_Scans_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DICOMAT_Associate_Scans_GUI_OutputFcn, ...
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


% --- Executes just before DICOMAT_Associate_Scans_GUI is made visible.
function DICOMAT_Associate_Scans_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DICOMAT_Associate_Scans_GUI (see VARARGIN)

% Choose default command line output for DICOMAT_Associate_Scans_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DICOMAT_Associate_Scans_GUI wait for user response (see UIRESUME)
% uiwait(handles.DICOMAT_Associate_Scans_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = DICOMAT_Associate_Scans_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in donebutton.
function donebutton_Callback(hObject, eventdata, handles)
% hObject    handle to donebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
