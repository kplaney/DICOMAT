
function GUI_data = show_scan_patient_data_scrolling_GUI(GUI_data)

% Check that we have the patient data needed
if isempty(GUI_data.Patient_Data_Struct) || isempty(GUI_data.Patient_Data_Associations)
  % Issue message
  uiwait(errordlg('Patient data not loaded', 'Select Patient Scans'));
  return;
end


% Check if the panels are already in place - if so then we are turning off
if isfield(GUI_data, 'visible_panel') && ishandle(GUI_data.visible_panel.panel_handle) && ...
	 isfield(GUI_data, 'behind_panel') && ishandle(GUI_data.behind_panel.panel_handle)
	
  % Turning off - so delete all text handles and uicontrols
  GUI_data = delete_scan_patient_data_scrolling_GUI(GUI_data);
else
  % Turning on - so set up:
  
  % Get a cell array of scan directory names for those scans selected
  Scan_Dirnames = GUI_data.relative_scan_dirpaths(GUI_data.selected_scan_dirs_idx);
  
  % Get field names for Patiet Data Struct
  Patient_Data_Struct_fieldnames = fieldnames(GUI_data.Patient_Data_Struct);
	
  % Get a list of Patient IDs
	field_idx = strmatch(GUI_data.Patient_Data_Associations.Patient_ID, GUI_data.patient_data_column_headings);
	Patient_ID_field_name = Patient_Data_Struct_fieldnames{field_idx};
  Patient_IDs = {GUI_data.Patient_Data_Struct.(Patient_ID_field_name)};
  num_patients = length(Patient_IDs);
	
  % Create a cell array of scan types and scan dates for each patient id
  Scan_dates_fields = GUI_data.Patient_Data_Associations.Scan_dates;
  Folder_identifiers = GUI_data.Patient_Data_Associations.Folder_identifiers;

  for f=1:length(Scan_dates_fields)
		field_idx = strmatch(Scan_dates_fields{f}, GUI_data.patient_data_column_headings);
		Scan_date_field_name = Patient_Data_Struct_fieldnames{field_idx};
		
    Scan_Dates_Array(1:num_patients,f) = {GUI_data.Patient_Data_Struct.(Scan_date_field_name)};

		if ~isempty(Folder_identifiers)
    	Scan_Types_Array(1:num_patients,f) = {Folder_identifiers{f}};
		else
			Scan_Types_Array(1:num_patients,f) = {''};
		end
  end
  
  % Set up scrolling GUI
  [visible_panel, behind_panel] = create_scan_patient_data_scrolling_GUI(GUI_data.uipanel2, Scan_Dirnames, Patient_IDs, Scan_Types_Array, Scan_Dates_Array);
  
  % Store panel data returned in GUI_data
  GUI_data.visible_panel = visible_panel;
  GUI_data.behind_panel = behind_panel;
  
  % Setup scrolling GUI uicontrol selections
  if ~isempty(GUI_data.Scan_Patient_Data_Struct)
    % Update menus according to previous selections
    update_scan_patient_data_scrolling_GUI(GUI_data, Scan_Types_Array, Scan_Dates_Array);
  else
    % Initialise menu selections form scratch
    initialise_scan_patient_data_scrolling_GUI(GUI_data, Patient_IDs, Scan_Types_Array, Scan_Dates_Array);
  end
end
