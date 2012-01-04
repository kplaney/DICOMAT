
function [GUI_data, validate_ok] = DICOMAT_Validate_Patient_Data_Association(GUI_data, Patient_Data_Associations)

error_msg = [];
validate_ok = true;

% User must have selected a Patient ID
if length(Patient_Data_Associations.Patient_ID) == 0
  validate_ok = false;
  error_msg = sprintf('Patient ID field not selected.\n');
end

% User must have selected at least one scan date
if length(Patient_Data_Associations.Scan_dates) == 0
  validate_ok = false;
  error_msg = sprintf('%sAt least one scan date must be selected.\n', error_msg);
end

% Make sure that no field is associated more than once
if length(unique(Patient_Data_Associations.Scan_dates)) < length(Patient_Data_Associations.Scan_dates)
  validate_ok = false;
  error_msg = sprintf('%sAt least one field associated multiple times.\n', error_msg);
end

% If not valid show error msg and return to GUI
if ~validate_ok  
  % Deactivate date format menu
  h = getfield(GUI_data, 'date_format_popupmenu');
  set(h, 'Enable', 'off');
  
  % Deactivate ok button
  h = getfield(GUI_data, 'okbutton');
  set(h, 'Enable', 'off');
  
  % Show error message and return
  uiwait(errordlg(error_msg, 'Validate patient data fields'));
  return;
else
  % Add patient data associations to parent figure GUI data
  GUI_data.Patient_Data_Associations = Patient_Data_Associations;
  
  % Update corresponding text field in GUI if associations are ok
  set(GUI_data.patient_data_association_text_field, 'String', 'Associated patient data fields');
  
  % Activate date format menu
  h = getfield(GUI_data, 'date_format_popupmenu');
  set(h, 'Enable', 'on');
  
  % Initialise date format menu
  if ~isempty(GUI_data.patient_data_scan_date_format)
    date_format_strings = get(h, 'String');
    selection = strmatch(GUI_data.patient_data_scan_date_format, date_format_strings, 'exact');
    
    if length(selection) == 1
      set(h, 'Value', selection);
    end
  end
  
  % Activate ok button
  h = getfield(GUI_data, 'okbutton');
  set(h, 'Enable', 'on');
end
