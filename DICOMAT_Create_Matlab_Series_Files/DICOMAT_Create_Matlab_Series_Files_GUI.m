function varargout = DICOMAT_Create_Matlab_Series_Files_GUI(varargin)
%DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI M-file for DICOMAT_Create_Matlab_Series_Files_GUI.fig
%      DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI, by itself, creates a new DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI or raises the existing
%      singleton*.
%
%      H = DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI returns the handle to a new DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI or the handle to
%      the existing singleton*.
%
%      DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI('Property','Value',...) creates a new DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to DICOMAT_Create_Matlab_Series_Files_GUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI('CALLBACK') and DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DICOMAT_CREATE_MATLAB_SERIES_FILES_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DICOMAT_Create_Matlab_Series_Files_GUI

% Last Modified by GUIDE v2.5 02-Nov-2011 22:11:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DICOMAT_Create_Matlab_Series_Files_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DICOMAT_Create_Matlab_Series_Files_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before DICOMAT_Create_Matlab_Series_Files_GUI is made visible.
function DICOMAT_Create_Matlab_Series_Files_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

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

% Initialise GUI fields
handles = DICOMAT_Create_Matlab_Series_Files_GUI_initialisation(handles);

% Set the figure window close request function
set(hObject, 'CloseRequestFcn', {@cancel_pushbutton_Callback, handles});

% Position GUI:
% First get Top Left Hand Corner (TLHC)
[TLHC_x, TLHC_y] = get_TLHC_for_next_GUI(handles.DICOMAT_GUI);

set(hObject, 'Units', 'normalized');
position_vec = get(hObject, 'Position');
position_vec(1:2) = [TLHC_x (TLHC_y - position_vec(4))];
set(hObject, 'Position', position_vec);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DICOMAT_Create_Matlab_Series_Files_GUI wait for user response (see UIRESUME)
% uiwait(handles.DICOMAT_Create_Matlab_Series_Files_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = DICOMAT_Create_Matlab_Series_Files_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if ~isempty(handles)
	varargout{1} = handles.output;
end


% --- Executes on button press in select_series_dirs_pushbutton.
function select_series_dirs_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to select_series_dirs_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'absolute_series_dirpaths') || isempty(handles.absolute_series_dirpaths)
	[absolute_series_dirpaths, annotated_series_dirpaths] = DICOMAT_Get_Series_Dirpaths(handles.absolute_scan_dirpaths(handles.selected_scan_dirs_idx), '--');
	handles.absolute_series_dirpaths = absolute_series_dirpaths;
	handles.annotated_series_dirpaths = strrep(annotated_series_dirpaths, strcat(handles.study_dir, filesep), '');
end

if ~isfield(handles, 'selected_series_dirs_idx')
	handles.selected_series_dirs_idx = [];
end

% Set position for Series Selection GUI
[TLHC_x, TLHC_y] = get_TLHC_for_next_GUI(handles.DICOMAT_GUI);
GUI_height = 0.7; GUI_width = 0.5;
GUI_position = [TLHC_x (TLHC_y - GUI_height) GUI_width GUI_height];

DICOMAT_Series_Selection_GUI(handles.DICOMAT_Create_Matlab_Series_Files_GUI, ...
														 GUI_position, ...
														 handles.annotated_series_dirpaths, ...
														 handles.selected_series_dirs_idx);

guidata(handles.DICOMAT_Create_Matlab_Series_Files_GUI, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB DIR/FILENAME OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in select_matlab_study_dir_pushbutton.
function select_matlab_study_dir_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to select_matlab_study_dir_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open a directory selection dialog box
handles.matlab_study_dir = uigetdir(handles.matlab_study_dir);

% Proceed if the user didn't press cancel
if handles.matlab_study_dir
	% Update the text field showing the current matlab study dir
	set(handles.matlab_study_dir_text_field, 'String', handles.matlab_study_dir);
	
	% Activate the matlab filename popupmenu & edit field, series type popupmenu and the Done button
	set(handles.matlab_filename_popupmenu, 'Enable', 'on');
	set(handles.matlab_filename_edit_field, 'Enable', 'on');
	set(handles.series_type_popupmenu, 'Enable', 'on');
	set(handles.pixel_class_popupmenu, 'Enable', 'on');
	
	% Update GUI figure with the latest handles struct
	guidata(handles.DICOMAT_Create_Matlab_Series_Files_GUI, handles);
end


% --- Executes on selection change in matlab_filename_popupmenu.
function matlab_filename_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to matlab_filename_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns matlab_filename_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from matlab_filename_popupmenu

menu_contents = cellstr(get(hObject, 'String'));
selected_menu_option = menu_contents{get(hObject, 'Value')};

switch selected_menu_option
	case 'Specify manually'
		set(handles.matlab_filename_edit_field, 'Enable', 'on');
	case 'Use DICOM Series Name'
		% Check that at most only one series has been selected for each selected scan
		scan_dirpaths = handles.absolute_scan_dirpaths(handles.selected_scan_dirs_idx);
		series_dirpaths = handles.absolute_series_dirpaths(handles.selected_series_dirs_idx);
		
		for s=1:length(scan_dirpaths)
			% If more than one series has been selected for a given scan then issue a warning and switch the menu selection back
			if length(find(strmatch(scan_dirpaths{s}, series_dirpaths))) > 1
				uiwait(errordlg('Cannot use DICOM Series Name as Matlab filename when more than one series is selected for a given scan'));
				set(hObject, 'Value', 1);
				return;
			end
		end
		
		set(handles.matlab_filename_edit_field, 'Enable', 'off', 'String', []);
	case 'Use Scan ID'
		set(handles.matlab_filename_edit_field, 'Enable', 'off', 'String', []);	
	otherwise
		uiwait(errordlg('Unrecognised Matlab series filename menu option selected...'));
end


% --- Executes during object creation, after setting all properties.
function matlab_filename_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matlab_filename_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function matlab_filename_edit_field_Callback(hObject, eventdata, handles)
% hObject    handle to matlab_filename_edit_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of matlab_filename_edit_field as text
%        str2double(get(hObject,'String')) returns contents of matlab_filename_edit_field as a double

matlab_filename = get(hObject, 'String');

if ~ischar(matlab_filename)
  uiwait(errordlg(sprintf('Invalid name for Matlab series file(s): %s', matlab_filename), 'Matlab series filename'));
  set(hObject, 'String', []);
end

% Append .mat to the end of the filename if it is missing
filename_len = length(matlab_filename);

if filename_len > 0 && (filename_len <= 4 || ~strcmp(lower(matlab_filename(end-3:end)), '.mat'))
	if matlab_filename(end) == '.'
		set(hObject, 'String', strcat(matlab_filename, 'mat'));
	else
		set(hObject, 'String', strcat(matlab_filename, '.mat'));
	end
end


% --- Executes during object creation, after setting all properties.
function matlab_filename_edit_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matlab_filename_edit_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%%%%%%%%%
% SERIES OPTIONS
%%%%%%%%%%%%%%%%

% --- Executes on selection change in series_type_popupmenu.
function series_type_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to series_type_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns series_type_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from series_type_popupmenu

DICOMAT_Series_Options_Mapping(handles, 'setup');


% --- Executes during object creation, after setting all properties.
function series_type_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to series_type_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pixel_class_popupmenu.
function pixel_class_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to pixel_class_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pixel_class_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pixel_class_popupmenu


% --- Executes during object creation, after setting all properties.
function pixel_class_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixel_class_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANONYMISE/RESET DICOM METADATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in anonymise_DICOM_checkbox_Callback.
function anonymise_DICOM_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to anonymise_DICOM_checkbox_Callback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.anonymise_DICOM = get(hObject, 'Value');
guidata(handles.DICOMAT_Create_Matlab_Series_Files_GUI, handles);


% --- Executes on button press in reset_dicom_metadata_pushbutton.
function reset_dicom_metadata_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to reset_dicom_metadata_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set position for Series Selection GUI
[TLHC_x, TLHC_y] = get_TLHC_for_next_GUI(handles.DICOMAT_GUI);
GUI_height = 0.6; GUI_width = 0.5;
GUI_position = [TLHC_x (TLHC_y - GUI_height) GUI_width GUI_height];

DICOMAT_Reset_DICOM_Metadata_GUI(handles.DICOMAT_Create_Matlab_Series_Files_GUI, GUI_position);


%%%%%%%%%%%%%%%%%%%
% LOG FILE SETTINGS
%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in select_log_dir_pushbutton.
function select_log_dir_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to select_log_dir_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open a directory selection dialog box
if isfield(handles, 'log_dir')
	handles.log_dir = uigetdir(handles.log_dir);
else
	handles.log_dir = uigetdir;
end

% Proceed if the user didn't press cancel
if handles.log_dir
	% Update the text field showing the log dir
	set(handles.log_dir_text_field, 'String', handles.log_dir);
	
	% Activate the log filename edit field
	set(handles.log_filename_edit_field, 'Enable', 'on');
	
	% Update GUI figure with the latest handles struct
	guidata(handles.DICOMAT_Create_Matlab_Series_Files_GUI, handles);
end


function log_filename_edit_field_Callback(hObject, eventdata, handles)
% hObject    handle to log_filename_edit_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of log_filename_edit_field as text
%        str2double(get(hObject,'String')) returns contents of log_filename_edit_field as a double

log_filename = get(hObject,'String');

% Check the entered log filename is valid
if ~ischar(log_filename)
  uiwait(errordlg(sprintf('Invalid name for log file (%s)', log_filename), 'Log file name'));
  set(hObject, 'String', []);
end


% --- Executes during object creation, after setting all properties.
function log_filename_edit_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to log_filename_edit_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%
% GO/CANCEL BUTTONS
%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in go_pushbutton.
function go_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to go_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check that we have a license for the image processing toolbox
if ~license('test','image_toolbox')
	uiwait(errordlg('To create Matlab Series Files requires a license for the image processing toolbox.', 'DICOMAT: DICOM to Matlab Converter'));
	return;
end

DICOMAT_Create_Matlab_Series_Files(handles);


% --- Executes on button press in cancel_pushbutton.
function cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'log_window') && ishandle(handles.log_window)
  close(handles.log_window);
end

DICOMAT_Update_Buttons(handles.DICOMAT_GUI);
delete(handles.DICOMAT_Create_Matlab_Series_Files_GUI);
