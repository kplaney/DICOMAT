
function handles = DICOMAT_Associate_Scans_GUI_initialisation(handles)

% Load DICOM study dir and selected scan dirs
handles.study_dir = getappdata(handles.DICOMAT_GUI, 'study_dir');
handles.relative_scan_dirpaths = getappdata(handles.DICOMAT_GUI, 'relative_scan_dirpaths');
handles.selected_scan_dirs_idx = getappdata(handles.DICOMAT_GUI, 'selected_scan_dirs_idx');
	
% Load study data
handles.patient_data_column_headings = getappdata(handles.DICOMAT_GUI, 'patient_data_column_headings');
handles.Patient_Data_Struct = getappdata(handles.DICOMAT_GUI, 'Patient_Data_Struct');
handles.Patient_Data_Associations = getappdata(handles.DICOMAT_GUI, 'Patient_Data_Associations');

% Load settings for associating scans with patient data
handles.Scan_Patient_Data_Struct = getappdata(handles.DICOMAT_GUI, 'Scan_Patient_Data_Struct');
