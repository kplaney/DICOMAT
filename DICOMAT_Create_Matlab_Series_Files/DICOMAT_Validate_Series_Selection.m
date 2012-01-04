
function DICOMAT_Validate_Series_Selection(h, ev, parent_GUI_handle, GUI_handle, listbox)

GUI_data = guidata(parent_GUI_handle);

% Check that the selections are valid (i.e. separator rows have not been selected)
series_strings = get(listbox, 'String');
selected_series_dirs_idx = get(listbox, 'Value');

for k=1:length(selected_series_dirs_idx)
	idx = selected_series_dirs_idx(k);
	series_dirpath = GUI_data.absolute_series_dirpaths{idx};
	
	if ~isdir(series_dirpath)
		uiwait(errordlg(sprintf('Invalid selection made: %s (row %d)', series_strings{idx}, idx), ...
										'Validate Series Selection'));
		return;
	end
end

% Update parent GUI data with the selections made
GUI_data.selected_series_dirs_idx = selected_series_dirs_idx;
guidata(parent_GUI_handle, GUI_data);

% Update the parent GUI
if ~isempty(selected_series_dirs_idx)
	% Update the associated text field and enable the Matlab dir selection button
	set(GUI_data.series_dirs_text_field, 'String', sprintf('Selected %d series directories', length(selected_series_dirs_idx)))
	set(GUI_data.select_matlab_study_dir_pushbutton, 'Enable', 'on');
	
	% Check which matlab filename mode is currently selected
	menu_contents = get(GUI_data.matlab_filename_popupmenu, 'String');
	menu_selection = get(GUI_data.matlab_filename_popupmenu, 'Value');

	% If "Specify manually" then clear the filename edit field (force user to enter a new name)
	if strcmp(menu_contents{menu_selection}, 'Specify manually')
		set(GUI_data.matlab_filename_edit_field, 'String', []);
	end
	
	% Reset the series type selection (so user is forced to choose a series type)
	set(GUI_data.series_type_popupmenu, 'Value', 1);
	DICOMAT_Clear_Series_Options(GUI_data);
else
	% Clear the associated text field and disable the Matlab dir selection button
	set(GUI_data.series_dirs_text_field, 'String', []);
	set(GUI_data.select_matlab_study_dir_pushbutton, 'Enable', 'off');
end

% Disable the Go button (it may have been enabled before)
set(GUI_data.go_pushbutton, 'Enable', 'off');

% Finally close the GUI
reactivate_parent_GUI(h, ev, parent_GUI_handle, GUI_handle);
