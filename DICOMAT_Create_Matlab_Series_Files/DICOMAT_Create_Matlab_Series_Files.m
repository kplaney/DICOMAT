
function DICOMAT_Create_Matlab_Series_Files(handles)

% First store the Matlab study dir in the main DICOMAT GUI handle
setappdata(handles.DICOMAT_GUI, 'matlab_study_dir', handles.matlab_study_dir);
	
% Get the series options for this series type
Series_Options = DICOMAT_Series_Options_Mapping(handles, 'readout');

% Check series options are not empty
if isempty(Series_Options)
	uiwait(errordlg('Please set the Series Options', mfilename));
	return;
end

% If anonymising the DICOM metadata, then create a cell array of anonymisation (field,update) pairs
if isfield(handles, 'anonymise_DICOM') && handles.anonymise_DICOM
	DICOM_anon_updates = DICOMAT_Get_DICOM_Fields_to_Anonymise;
	[DICOM_anon_updates{:,2}] = deal('');
else
	DICOM_anon_updates = [];
end

% Get the cell array of user-specified DICOM fields to update/reset
if isfield(handles, 'DICOM_field_updates') && ~isempty(handles.DICOM_field_updates)
	DICOM_field_updates = handles.DICOM_field_updates;
else
	DICOM_field_updates = [];
end

% Create a final updates cell by concatenating the anon and the user updates
% Note that the anonymisation fields should come first so that the user is able
% to both anonymise data and set new values for fields like patient name etc.
DICOM_field_updates = [DICOM_anon_updates; DICOM_field_updates];

% Set up log file and log window - store handles so we can re-use them later
handles = setup_log_file_and_log_window(handles, 'DICOMAT Log Window');
guidata(handles.DICOMAT_Create_Matlab_Series_Files_GUI, handles);

% Create a waitbar
waitbar_handle = create_waitbar('Create Matlab Files', 8);

% Get absolute directory paths for the scan and series dirs to process
scan_dirpaths = handles.absolute_scan_dirpaths(handles.selected_scan_dirs_idx);
series_dirpaths = handles.absolute_series_dirpaths(handles.selected_series_dirs_idx);
num_scans = size(scan_dirpaths,1);

% Loop over all scans
for s=1:num_scans
	% Extract the Scan ID
	if strcmp(scan_dirpaths{s}, handles.study_dir)
		% If the selected study format is 'Series/DICOM Files' then set the scan ID to '.'
		% so that files are created directly in the specified Matlab study dir
		scan_id = '.';
	else
		% Otherwise we extract the Scan ID from the complete scan dirpath by stripping out the study dir
		scan_id = strrep(scan_dirpaths{s}, strcat(handles.study_dir, filesep), '');
	end
	
	% Check waitbar
	if check_if_waitbar_cancel_pressed(waitbar_handle)
		delete(waitbar_handle);
		return;
	end
	
	% Update wairbar
	update_waitbar((s-1)/num_scans, waitbar_handle, sprintf('Processing: %s (%d of %d)', scan_id, s, num_scans));
	set(waitbar_handle, 'Name', scan_id);
	
  % Get the selected series directories for this scan
  selected_scan_series_idx = strmatch(scan_dirpaths{s}, series_dirpaths);
  selected_scan_series_dirs = series_dirpaths(selected_scan_series_idx);

  % Check that selected series dir list is not empty
  if ~isempty(selected_scan_series_dirs)
    % Set up the Matlab series filename depending on the series type selection
		matlab_filename_options = cellstr(get(handles.matlab_filename_popupmenu, 'String'));
		matlab_filename_type = matlab_filename_options{get(handles.matlab_filename_popupmenu, 'Value')};
		
    switch matlab_filename_type
     case 'Specify manually'
			matlab_series_filename = get(handles.matlab_filename_edit_field, 'String');

     case 'Use DICOM Series Name'
      [tmp, series_name] = fileparts(selected_scan_series_dirs{1});
      matlab_series_filename = strcat(series_name, '.mat');

     case 'Use Scan ID'
			if scan_id == '.'
				% If the selected study format is 'Series/DICOM Files' then use the name of the study dir
				[tmp, study_dirname] = fileparts(handles.study_dir);
				matlab_series_filename = strcat(study_dirname, '.mat');
			else
				% Otherwise use the scan id we determined previously and convert any filesep characters to underscores
      	matlab_series_filename = strcat(strrep(scan_id, filesep, '_'), '.mat');
			end

		otherwise
			uiwait(errordlg(sprintf('Unknown matlab filename option: %s', matlab_filename_type), mfilename));
			return;
    end
	
		% Check the matlab series filename is valid
		if isempty(matlab_series_filename) || ~ischar(matlab_series_filename)
			uiwait(errordlg(sprintf('Invalid matlab series file name: %s', matlab_series_filename), mfilename));
			return;
		end
		
    % Setup the full Matlab series filepath
    matlab_series_filepath = fullfile(handles.matlab_study_dir, scan_id, matlab_series_filename);
    
		% Create the Matlab series dir
		[success, mkdir_msg] = mkdir(handles.matlab_study_dir, scan_id);
		
		if ~success
			uiwait(errordlg(sprintf('Unable to create scan dir: %s in matlab study dir: %s\n, Error message: %s', ...
											scan_id, handles.matlab_study_dir, mkdir_msg), mfilename));
			return;
		end
		
		% Call the function to create the matlab file for this series type
		ran_ok = DICOMAT_Series_File_Creation_Mapping(handles, waitbar_handle, scan_id, selected_scan_series_dirs, matlab_series_filepath, Series_Options);
		
		% Check if everything ran ok and we have a resulting matlab file
		if ran_ok && exist(matlab_series_filepath, 'file')
			% Store the particular DICOM series dirs used in the matlab file
			DICOM_series_dirs = selected_scan_series_dirs;
			save(matlab_series_filepath, 'DICOM_series_dirs', '-append');
		
  		% Optionally add patient data / scan patient data to matlab file 
  		if isfield(handles, 'Patient_Data_Struct') && ~isempty(handles.Patient_Data_Struct) && ...
				 isfield(handles, 'Scan_Patient_Data_Struct') && ~isempty(handles.Scan_Patient_Data_Struct)

    		update_waitbar(1, waitbar_handle, 'Adding patient params to series file...');
    		Patient_Params = DICOMAT_Get_Patient_Params(scan_id, handles.Patient_Data_Struct, handles.Scan_Patient_Data_Struct, ...
    																						handles.log_file, handles.log_window_text);

    		if ~isempty(Patient_Params)
      		save(matlab_series_filepath, 'Patient_Params', '-append');
    		end
  		end

			% Update DICOM fields - either for anonymisation and/or user-defined resets/updates
			if ~isempty(DICOM_field_updates)
				update_waitbar(1, waitbar_handle, 'Updating DICOM metadata...');
				DICOMAT_Reset_DICOM_Metadata(DICOM_field_updates, matlab_series_filepath, handles.log_file, handles.log_window_text);
			end
		else
			output_msg(sprintf('Problem encountered creating matlab series file: %s', matlab_series_filename), handles.log_file, handles.log_window_text);
			
			% Delete waitbar
			if ishandle(waitbar_handle)
			  delete(waitbar_handle);
			end
			
			return;
		end
  else
    output_msg(sprintf('No series directories selected for scan: %s. Skipping...', scan_id), handles.log_file, handles.log_window_text);
  end
end

% CLose the log window if no messages were written to it
if isfield(handles, 'log_window_text') && isempty(get(handles.log_window_text, 'str'))
	if isfield(handles, 'log_window') && ishandle(handles.log_window)
	  close(handles.log_window);
	end
end

% Delete waitbar
if ishandle(waitbar_handle)
  delete(waitbar_handle);
end