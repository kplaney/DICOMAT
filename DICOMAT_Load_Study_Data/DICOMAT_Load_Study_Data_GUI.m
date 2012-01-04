
function varargout = DICOMAT_Load_Study_Data_GUI(varargin)

% DICOMAT_Load_Study_Data_GUI M-file for DICOMAT_Load_Study_Data_GUI.fig
%      DICOMAT_Load_Study_Data_GUI, by itself, creates a new DICOMAT_Load_Study_Data_GUI or raises the existing
%      singleton*.
%
%      H = DICOMAT_Load_Study_Data_GUI returns the handle to a new DICOMAT_Load_Study_Data_GUI or the handle to
%      the existing singleton*.
%
%      DICOMAT_Load_Study_Data_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DICOMAT_Load_Study_Data_GUI.M with the given input arguments.
%
%      DICOMAT_Load_Study_Data_GUI('Property','Value',...) creates a new DICOMAT_Load_Study_Data_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DICOMAT_Load_Study_Data_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DICOMAT_Load_Study_Data_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DICOMAT_Load_Study_Data_GUI

% Last Modified by GUIDE v2.5 11-Nov-2009 09:22:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DICOMAT_Load_Study_Data_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DICOMAT_Load_Study_Data_GUI_OutputFcn, ...
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


% --- Executes just before DICOMAT_Load_Study_Data_GUI is made visible.
function DICOMAT_Load_Study_Data_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DICOMAT_Load_Study_Data_GUI (see VARARGIN)

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
set_tag_for_GUI_child(hObject, handles.DICOMAT_GUI, 'Load Study Data GUI');

% Initialise GUI fields
handles = DICOMAT_Load_Study_Data_GUI_initialisation(handles);

% Set the figure window close request function
set(hObject, 'CloseRequestFcn', {@exitbutton_Callback, handles});

% Position GUI:
% First get Top Left Hand Corner (TLHC)
[TLHC_x, TLHC_y] = get_TLHC_for_next_GUI(handles.DICOMAT_GUI);

set(hObject, 'Units', 'normalized');
position_vec = get(hObject, 'Position');
position_vec(1:2) = [TLHC_x (TLHC_y - position_vec(4))];
set(hObject, 'Position', position_vec);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DICOMAT_Load_Study_Data_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DICOMAT_Load_Study_Data_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_study_data_file_Callback.
function select_study_data_file_Callback(hObject, eventdata, handles)
% hObject    handle to select_study_data_file_Callback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.study_data_file)
  filter_spec = handles.study_data_file;
else
  filter_spec = '~/Data/*.txt';
end

[filename,pathname] = uigetfile(filter_spec, 'Select patient data file');

if ~isnumeric(filename) & ~isnumeric(pathname)
  study_data_file = sprintf('%s%s', pathname, filename);
  
  % Read patient data file
  [Patient_Data_Struct, column_headings] = read_patient_data_file(study_data_file);
  
  % Save into GUI data
  handles.study_data_file = study_data_file;
  handles.Patient_Data_Struct = Patient_Data_Struct;
  handles.patient_data_column_headings = column_headings;
  
  handles.Patient_Data_Associations = [];
  handles.patient_data_scan_date_format = [];

  h = getfield(handles, 'study_data_file_text_field');
  set(h, 'String', study_data_file);
  
  h = getfield(handles, 'view_study_data_file');
  set(h, 'enable', 'on');
  
  h = getfield(handles, 'associate_patient_data_fields');
  set(h, 'enable', 'on');
    
  h = getfield(handles, 'patient_data_association_text_field');
  set(h, 'String', []);
end

% Update GUI figure with the latest handles struct
guidata(handles.DICOMAT_Load_Study_Data_GUI, handles);


% --- Executes on button press in view_study_data_file.
function view_study_data_file_Callback(hObject, eventdata, handles)
% hObject    handle to view_study_data_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Patient_Data_Struct = handles.Patient_Data_Struct;
column_headings = handles.patient_data_column_headings;

text_lines = convert_struct_array_to_array_of_text_strings(Patient_Data_Struct, column_headings);
window_title = sprintf('Patient Data File [%s]', handles.study_data_file);

if isfield(handles, 'file_fig') && ishandle(handles.file_fig)
  figure(handles.file_fig);
  set(handles.file_fig, 'Name', window_title);
else
  handles.file_fig = figure('Units', 'normalized', 'Position', [0.4,0.4,0.8,0.6], ...
                            'Name', window_title, 'Numbertitle', 'off', ...
                            'toolbar', 'none', 'Visible', 'off');
  
  movegui(handles.file_fig, 'center');  
  set(handles.file_fig, 'Visible', 'on');
end

if isfield(handles, 'file_text_handle') && ishandle(handles.file_text_handle)
  set(handles.file_text_handle, 'string', text_lines);
else
  handles.file_text_handle = uicontrol('style', 'listbox', 'string', text_lines, ...
                                        'FontName', 'FixedWidth', 'Fontunits', 'points', 'Fontsize', 10, ...
                                        'Position', [0 0 1 1], 'HorizontalAlignment', 'left', ...
                                        'enable', 'on');
end

% Update GUI figure with the latest handles struct
guidata(handles.DICOMAT_Load_Study_Data_GUI, handles);


% --- Executes on button press in associate_patient_data_fields.
function associate_patient_data_fields_Callback(hObject, eventdata, handles)
% hObject    handle to associate_patient_data_fields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DICOMAT_Create_Patient_Data_Association_GUI(handles.patient_data_column_headings, ...
																		handles.DICOMAT_Load_Study_Data_GUI, ...
																		handles.Patient_Data_Associations);


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the format for dates in the patient data file
h = getfield(handles, 'date_format_popupmenu');
date_format_strings = get(h, 'String');
date_format_selection = get(h, 'Value');
scan_date_format = date_format_strings{date_format_selection};

% Copy patient data variables across to root
setappdata(handles.DICOMAT_GUI, 'study_data_file', handles.study_data_file);
setappdata(handles.DICOMAT_GUI, 'patient_data_column_headings', handles.patient_data_column_headings);
setappdata(handles.DICOMAT_GUI, 'Patient_Data_Struct', handles.Patient_Data_Struct);
setappdata(handles.DICOMAT_GUI, 'Patient_Data_Associations', handles.Patient_Data_Associations);
setappdata(handles.DICOMAT_GUI, 'patient_data_scan_date_format', scan_date_format);

DICOMAT_Update_Buttons(handles.DICOMAT_GUI);
close(handles.DICOMAT_Load_Study_Data_GUI);


% --- Executes on button press in exitbutton.
function exitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DICOMAT_Update_Buttons(handles.DICOMAT_GUI);
delete(handles.DICOMAT_Load_Study_Data_GUI);
