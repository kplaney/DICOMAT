
function varargout = DICOMAT(varargin)
% DICOMAT M-file for DICOMAT.fig
%      DICOMAT, by itself, creates a new DICOMAT or raises the existing
%      singleton*.
%
%      H = DICOMAT returns the handle to a new DICOMAT or the handle to
%      the existing singleton*.
%
%      DICOMAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DICOMAT.M with the given input arguments.
%
%      DICOMAT('Property','Value',...) creates a new DICOMAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DICOMAT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DICOMAT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DICOMAT

% Last Modified by GUIDE v2.5 18-Nov-2011 13:54:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DICOMAT_OpeningFcn, ...
                   'gui_OutputFcn',  @DICOMAT_OutputFcn, ...
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


% --- Executes just before DICOMAT is made visible.
function DICOMAT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DICOMAT (see VARARGIN)


% Choose default command line output for DICOMAT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Check that we have a license for the image processing toolbox
if ~license('test','image_toolbox')
	uiwait(errordlg('This software requires a license for the image processing toolbox. You can proceed but you will not be able to convert any DICOM files...', ...
					 		    'DICOMAT: DICOM to Matlab Converter'));
end


% Position GUI to top left of screen
set(hObject, 'Units', 'normalized');
position_vec = get(hObject, 'Position');
position_vec(1:2) = [0.01 0.99-position_vec(4)];
set(hObject, 'Position', position_vec);

% Add DICOMAT subdirs to Matlab path
DICOMAT_filepath = mfilename('fullpath');
DICOMAT_dirpath = fileparts(DICOMAT_filepath);
addpath(genpath(DICOMAT_dirpath));


% --- Outputs from this function are returned to the command line.
function varargout = DICOMAT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if ~isempty(handles)
	varargout{1} = handles.output;
end


% --- Executes on button press in select_scans_button.
function select_scans_Callback(hObject, eventdata, handles)
% hObject    handle to select_scans_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set the options to set up the Select Scans GUI
setappdata(handles.DICOMAT, 'select_study_dir_button_text', 'Select DICOM study dir');
setappdata(handles.DICOMAT, 'study_format_popupmenu_strings', ...
					{'','Patient/Scan/Series/DICOM Files','Scan/Series/DICOM Files', 'Series/DICOM Files'});
setappdata(handles.DICOMAT, 'update_buttons_function_handle', @DICOMAT_Update_Buttons);

DICOMAT_Disable_Buttons(handles.DICOMAT);
Select_Scans_GUI(handles.DICOMAT);


% --- Executes on button press in load_study_data_button.
function load_study_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_study_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%DICOMAT_Disable_Buttons(handles.DICOMAT);
DICOMAT_Load_Study_Data_GUI(handles.DICOMAT);


% --- Executes on button press in associate_scans_button.
function associate_scans_Callback(hObject, eventdata, handles)
% hObject    handle to associate_scans_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%DICOMAT_Disable_Buttons(handles.DICOMAT);
DICOMAT_Associate_Scans_GUI(handles.DICOMAT);


% --- Executes on button press in create_matlab_series_files_button.
function create_matlab_series_files_button_Callback(hObject, eventdata, handles)
% hObject    handle to create_matlab_series_files_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DICOMAT_Disable_Buttons(handles.DICOMAT);
DICOMAT_Create_Matlab_Series_Files_GUI(handles.DICOMAT);


% --- Executes on button press in quit_button.
function quit_button_Callback(hObject, eventdata, handles)
% hObject    handle to quit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(findobj('-regexp', 'Tag', 'DICOMAT*'));
