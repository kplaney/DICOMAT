
function DICOMAT_Update_Buttons(DICOMAT_GUI)

% First disable all buttons to get to a default state
DICOMAT_Disable_Buttons(DICOMAT_GUI);

% Retrieve relevant variable set by scan selection GUI
scan_dir_depth = getappdata(DICOMAT_GUI, 'scan_dir_depth');
selected_scan_dirs_idx = getappdata(DICOMAT_GUI, 'selected_scan_dirs_idx');

% Enable the scan selection button - should always be enabled.
DICOMAT_guidata = guidata(DICOMAT_GUI);
set(DICOMAT_guidata.select_scans_button, 'Enable', 'on');

% See which other buttons we should enable
if ~isempty(scan_dir_depth)
	% If scan_dir_depth is zero then we are just dealing with a single set of DICOM series for 1 scan only
	% so just enable the create matlab series file button
	if scan_dir_depth == 0
		set(DICOMAT_guidata.create_matlab_series_files_button, 'Enable', 'on');
	else
		% If we have a patient/scan/series or scan/series hierarchy, check first if any scans were selected
		if ~isempty(selected_scan_dirs_idx)
			% Yes - so enable the load study data button
			set(DICOMAT_guidata.load_study_data_button, 'Enable', 'on');
			
			% Check if we've already loaded some study data successfully
			Patient_Data_Struct = getappdata(DICOMAT_GUI, 'Patient_Data_Struct');
			Patient_Data_Associations = getappdata(DICOMAT_GUI, 'Patient_Data_Associations');
			
			if ~isempty(Patient_Data_Struct) && ~isempty(Patient_Data_Associations)
				% If so enable the scan association button
				set(DICOMAT_guidata.associate_scans_button, 'Enable', 'on');
			end
			
			% Finally enable the create matlab series file button
			set(DICOMAT_guidata.create_matlab_series_files_button, 'Enable', 'on');
		end
	end
end
