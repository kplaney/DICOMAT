
function handles = DICOMAT_Create_Matlab_Series_Files_GUI_initialisation(handles)

% Get DICOM study dir and update text field
handles.study_dir = getappdata(handles.DICOMAT_GUI, 'study_dir');

% Get the scan selection
handles.absolute_scan_dirpaths = getappdata(handles.DICOMAT_GUI, 'absolute_scan_dirpaths');
handles.selected_scan_dirs_idx = getappdata(handles.DICOMAT_GUI, 'selected_scan_dirs_idx');

% Get the series selection
handles.absolute_series_dirpaths = getappdata(handles.DICOMAT_GUI, 'absolute_series_dirpaths');
handles.annotated_series_dirpaths = getappdata(handles.DICOMAT_GUI, 'annotated_series_dirpaths');

% Get the selected series dir idx
handles.selected_series_dirs_idx = getappdata(handles.DICOMAT_GUI, 'selected_series_dirs_idx');

if ~isempty(handles.selected_series_dirs_idx)
	set(handles.series_dirs_text_field, 'String', sprintf('Selected %d series directories', length(handles.selected_series_dirs_idx)));
else
	set(handles.series_dirs_text_field, 'String', []);
end

% Get MATLAB study dir and update text field
handles.matlab_study_dir = getappdata(handles.DICOMAT_GUI, 'matlab_study_dir');
set(handles.matlab_study_dir_text_field, 'String', handles.matlab_study_dir);

% Activate the matlab filename popupmenu & edit field, and series type popupmenu
if ~isempty(handles.matlab_study_dir)
	set(handles.matlab_filename_popupmenu, 'Enable', 'on');
	set(handles.matlab_filename_edit_field, 'Enable', 'on');
	set(handles.series_type_popupmenu, 'Enable', 'on');
	set(handles.pixel_class_popupmenu, 'Enable', 'on');
end

% Get patient data and scan patient data mapping structs
handles.Patient_Data_Struct = getappdata(handles.DICOMAT_GUI, 'Patient_Data_Struct');
handles.Scan_Patient_Data_Struct = getappdata(handles.DICOMAT_GUI, 'Scan_Patient_Data_Struct');
