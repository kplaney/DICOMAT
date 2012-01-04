
function handles = DICOMAT_Load_Study_Data_GUI_initialisation(handles)

% Copy patient data variables from root
handles.study_data_file = getappdata(handles.DICOMAT_GUI, 'study_data_file');
handles.patient_data_column_headings = getappdata(handles.DICOMAT_GUI, 'patient_data_column_headings');
handles.Patient_Data_Struct = getappdata(handles.DICOMAT_GUI, 'Patient_Data_Struct');
handles.Patient_Data_Associations = getappdata(handles.DICOMAT_GUI, 'Patient_Data_Associations');
handles.patient_data_scan_date_format = getappdata(handles.DICOMAT_GUI, 'patient_data_scan_date_format');

if ~isempty(handles.study_data_file) && ~isempty(handles.Patient_Data_Struct) && ~isempty(handles.Patient_Data_Associations)
  h = getfield(handles, 'study_data_file_text_field');
  set(h, 'String', handles.study_data_file);
  
  h = getfield(handles, 'view_study_data_file');
  set(h, 'enable', 'on');
  
  h = getfield(handles, 'associate_patient_data_fields');
  set(h, 'enable', 'on');

  if ~isempty(handles.Patient_Data_Associations)
    handles = DICOMAT_Validate_Patient_Data_Association(handles, handles.Patient_Data_Associations);
  end
end