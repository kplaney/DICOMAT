
function DICOMAT_Process_Patient_Data_Association(src, eventdata, parent_handle, button_type)

% Get figure GUI data
[obj, fig] = gcbo;
GUI_data = guidata(fig);

% Initialise patient data associations struct with empty fields
Patient_Data_Associations.Patient_ID = [];
Patient_Data_Associations.Scan_dates = [];
Patient_Data_Associations.Folder_identifiers = [];

% Check if the user pressed ok
if strcmp(lower(button_type), 'ok')
	menu_selection = get(GUI_data.menu_ui(1), 'Value');

	if menu_selection > 1
		menu_entries = get(GUI_data.menu_ui(1), 'String');
		Patient_Data_Associations.Patient_ID = menu_entries{menu_selection};
	end
	
  % Process each field
  for field_idx=2:length(GUI_data.fields)
    menu_selection = get(GUI_data.menu_ui(field_idx), 'Value');

		if menu_selection > 1
			menu_entries = get(GUI_data.menu_ui(field_idx), 'String');
			idx = length(Patient_Data_Associations.Scan_dates) + 1;
			Patient_Data_Associations.Scan_dates{idx} = menu_entries{menu_selection};
			
			folder_id = get(GUI_data.edit_ui(field_idx), 'String');
			Patient_Data_Associations.Folder_identifiers{idx} = folder_id;
		end
	end
	
  % Get parent figure GUI data
  parent_GUI_data = guidata(parent_handle);

  % Validate associations
  [parent_GUI_data, validate_ok] = DICOMAT_Validate_Patient_Data_Association(parent_GUI_data, Patient_Data_Associations);
  
  if validate_ok
    % Save GUI data into parent figure handle
    guidata(parent_handle, parent_GUI_data);

    % Close figure window
    close(fig);
  end
else
  % Close figure window
  close(fig);
end
