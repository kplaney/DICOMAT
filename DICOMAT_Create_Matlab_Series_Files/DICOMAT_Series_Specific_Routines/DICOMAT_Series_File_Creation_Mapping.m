
function ran_ok = DICOMAT_Series_File_Creation_Mapping(handles, waitbar_handle, scan_id, selected_scan_series_dirs, matlab_series_filepath, Series_Options)

ran_ok = false;

menu_contents = cellstr(get(handles.series_type_popupmenu, 'String'));
selected_series_type = menu_contents{get(handles.series_type_popupmenu, 'Value')};

Series_Options.series_type = selected_series_type;

% Process according to selected series type
switch selected_series_type
	case 'Generic'
		% Create arbitrary series matlab file:
  	ran_ok = DICOMAT_Create_Matlab_Generic_File(scan_id, selected_scan_series_dirs, matlab_series_filepath, Series_Options, ...
  																	 						handles.log_file, handles.log_window_text, waitbar_handle);

	case 'DCE-MRI'
  	% Create DCE-MRI matlab file:
  	ran_ok = DICOMAT_Create_Matlab_Dynamic_Acquisition_File(scan_id, selected_scan_series_dirs, matlab_series_filepath, Series_Options, ...
  																					 								handles.log_file, handles.log_window_text, waitbar_handle);

	case 'BOLD-MRI'
  	% Create BOLD-MRI matlab file:
  	ran_ok = DICOMAT_Create_Matlab_BOLD_MRI_File(scan_id, selected_scan_series_dirs, matlab_series_filepath, Series_Options, ...
  																					  	 handles.log_file, handles.log_window_text, waitbar_handle);

	case 'DW-MRI'
  	% Create DWI-MRI matlab file:
  	ran_ok = DICOMAT_Create_Matlab_DWI_MRI_File(scan_id, selected_scan_series_dirs, matlab_series_filepath, Series_Options, ...
  																					 		handles.log_file, handles.log_window_text, waitbar_handle);

	case 'dPET/dCT'
  	% Create dynamic PET or CT matlab file:
  	ran_ok = DICOMAT_Create_Matlab_Dynamic_Acquisition_File(scan_id, selected_scan_series_dirs, matlab_series_filepath, Series_Options, ...
  																					 								handles.log_file, handles.log_window_text, waitbar_handle);
	otherwise
 		uiwait(errordlg('Please select a valid series type', 'DICOMAT'));
		return;
end
