
function DICOMAT_Validate_DICOM_Fields_Entries(h, ev, parent_GUI_handle, fig, ui_handles)

DICOM_field_updates = [];
idx = 1;

% Loop over all rows of ui handles
for row=1:size(ui_handles,1)
	% Check if we have a popupmenu or edit field in the first column for this row
	switch get(ui_handles(row,1), 'style')
		case 'popupmenu'
			ui_selection = get(ui_handles(row,1), 'value');
			ui_menu_entries = get(ui_handles(row,1), 'string');
			DICOM_field_name = ui_menu_entries{ui_selection};			
		case 'edit'
			DICOM_field_name = get(ui_handles(row,1), 'string');
	end
	
	% If DICOM field entry is not empty then proceed
	if ~isempty(DICOM_field_name)
		% Check if this is a valid name for a struct field by trying to create a struct with this field
		try
			struct(DICOM_field_name, []);
		catch
			uiwait(errordlg(sprintf('DICOM field: %s is not a valid struct field name', DICOM_field_name), ...
						 'Validate DICOM Field Entries'));
			return;
		end
		
		% Store the DICOM field and the new value for it
		DICOM_field_updates{idx,1} = DICOM_field_name;
		DICOM_field_updates{idx,2} = get(ui_handles(row,2), 'string');
		
		% Get the data type for this field
		ui_selection = get(ui_handles(row,3), 'value');
		ui_menu_entries = get(ui_handles(row,3), 'string');
		ui_contents = ui_menu_entries{ui_selection};
		
		% Check that the data type is not empty - if so warn user and return to GUI
		if ~isempty(ui_contents)
			% If the selected data type is numeric - check that the new value corresponds to a valid number
			if strcmp(ui_contents, 'numeric')
				[number, valid_number] = str2num(DICOM_field_updates{idx,2});
				
				if ~valid_number
					% Problem - could not convert entry to a number
					uiwait(errordlg(sprintf('Value entered for DICOM field: %s is not a valid number', DICOM_field_name), ...
								 'Validate DICOM Field Entries'));
					return;
				else
					% Store the number
					DICOM_field_updates{idx,2} = number;
				end
			end
		else
			uiwait(errordlg(sprintf('No type selected for DICOM field: %s', DICOM_field_name), 'Validate DICOM Field Entries'));
			return;
		end
		
		idx = idx+1;
	end
end


% Check that no DICOM fields have been selected/entered multiple times
if ~isempty(DICOM_field_updates) && length(DICOM_field_updates(:,1)) > length(unique(DICOM_field_updates(:,1)))
	uiwait(errordlg('Some DICOM Fields have been selected or entered more than once...', 'Validate DICOM Field Entries'));
	return;
end

% Update parent GUI data with the DICOM fields to update
GUI_data = guidata(parent_GUI_handle);
GUI_data.DICOM_field_updates = DICOM_field_updates;
guidata(parent_GUI_handle, GUI_data);

% Update the parent GUI
if ~isempty(DICOM_field_updates)
	set(GUI_data.reset_dicom_text_field, 'String', sprintf('Resetting %d DICOM fields', size(DICOM_field_updates,1)));
else
	set(GUI_data.reset_dicom_text_field, 'String', []);
end

% Finally close the GUI
reactivate_parent_GUI(h, ev, parent_GUI_handle, fig);
