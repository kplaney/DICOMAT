
function varargout = DICOMAT_Associate_Scans_GUI(varargin)

% DICOMAT_Associate_Scans_GUI M-file for DICOMAT_Associate_Scans_GUI.fig
%      DICOMAT_Associate_Scans_GUI, by itself, creates a new DICOMAT_Associate_Scans_GUI or raises the existing
%      singleton*.
%
%      H = DICOMAT_Associate_Scans_GUI returns the handle to a new DICOMAT_Associate_Scans_GUI or the handle to
%      the existing singleton*.
%
%      DICOMAT_Associate_Scans_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DICOMAT_Associate_Scans_GUI.M with the given input arguments.
%
%      DICOMAT_Associate_Scans_GUI('Property','Value',...) creates a new DICOMAT_Associate_Scans_GUI or raises the
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

% Last Modified by GUIDE v2.5 02-Nov-2011 22:08:33

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

% Check that the handle to the main DICOMAT_GUI was passed
if length(varargin) < 1 || ~ishandle(varargin{1})
	disp(sprintf('%s: must pass a handle to the main DICOMAT GUI as the first argument.', mfilename));
	close(hObject);
	return;
end

% Choose default command line output for Select_Scans_GUI
handles.output = hObject;

% Add DICOMAT_GUI handle to handles struct for this GUI
handles.DICOMAT_GUI = varargin{1};

% Set the Tag for this GUI and prefix with the parent GUI name to enable easy deletion
set_tag_for_GUI_child(hObject, handles.DICOMAT_GUI, 'Associate Scans GUI');

% Initialise GUI fields
handles = DICOMAT_Associate_Scans_GUI_initialisation(handles);

% Set up patient data associations scrolling GUI
handles = show_scan_patient_data_scrolling_GUI(handles);

% Set the figure window close request function
set(hObject, 'CloseRequestFcn', {@cancelbutton_Callback, handles});

% Position GUI:
% First get Top Left Hand Corner (TLHC)
[TLHC_x, TLHC_y] = get_TLHC_for_next_GUI(handles.DICOMAT_GUI);

set(hObject, 'Units', 'normalized');
position_vec = get(hObject, 'Position');
position_vec(1:2) = [TLHC_x (TLHC_y - position_vec(4))];
set(hObject, 'Position', position_vec);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DICOMAT_Associate_Scans_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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

% 
valid_selections = validate_patient_scan_associations(handles);

if valid_selections
  Scan_Patient_Data_Struct = read_out_patient_scan_associations(handles);
  
  % 
  if ~isempty(Scan_Patient_Data_Struct)
    setappdata(handles.DICOMAT_GUI, 'Scan_Patient_Data_Struct', Scan_Patient_Data_Struct);
  end
else
  uiwait(errordlg('Selections are not valid', 'DICOMAT Associate Scans'));
	return;
end

close(handles.DICOMAT_Associate_Scans_GUI);


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.DICOMAT_Associate_Scans_GUI);
