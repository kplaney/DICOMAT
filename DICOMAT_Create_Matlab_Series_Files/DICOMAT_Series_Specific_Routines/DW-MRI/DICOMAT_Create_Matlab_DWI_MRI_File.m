
function ran_ok = DICOMAT_Create_Matlab_DWI_MRI_File(scan_id, scan_series_dirs, matlab_series_filepath, ...
																				 					Series_Options, log_file, log_window_text, varargin)

ran_ok = false;

% Set up waitbar handle
if length(varargin)
  waitbar_handle = varargin{1};
else
  waitbar_handle = [];
end

% Loop over each DWI series and read in DICOM data
for n=1:length(scan_series_dirs)
  % Read the DWI DICOM files for this series into Matlab
  [DWI_Data, DWI_Info, DWI_Acquisition_Times, warning_msgs] = DICOMAT_Load_DWI_MRI_Series_Files(scan_series_dirs(n), Series_Options.pixel_class, ...
  																																													log_file, log_window_text, waitbar_handle);
  
	if isempty(DWI_Data)
		return;
	end
	
  if exist('Data', 'var')
    start_idx = length(Data)+1;
    stop_idx = start_idx + length(DWI_Data) - 1;
    Data(start_idx:stop_idx) = DWI_Data;
  else
    Data = DWI_Data;
  end
  
  if exist('Info', 'var')
    start_idx = length(Info)+1;
    stop_idx = start_idx + length(DWI_Info) - 1;
    Info(start_idx:stop_idx) = DWI_Info;
  else
    Info = DWI_Info;
  end

  if exist('Acquisition_Times', 'var')
    start_idx = length(Acquisition_Times)+1;
    stop_idx = start_idx + length(DWI_Acquisition_Times) - 1;
    Acquisition_Times(start_idx:stop_idx) = DWI_Acquisition_Times;
  else
    Acquisition_Times = DWI_Acquisition_Times;
  end
        
  if ~isempty(warning_msgs)
    process_error_msg(warning_msgs, log_file, log_window_text);
  end
end


if ~isempty(Data)
  % Number of DWI "b-values"
  num_b_values = length(Data);
  
  % Check that the dimensions of all the MR volumes are consistent
  [num_b_value1_rows, num_b_value1_cols, num_b_value1_slices] = size(Data{1});
	
  for n=2:num_b_values
    [num_rows, num_cols, num_slices] = size(Data{n});
    
    if num_rows ~= num_b_value1_rows
      process_error_msg(sprintf('Scan ID: %s - Number of image rows (%d) for first b-value does not match number of image rows (%d) for b-value #%d', ...
                                scan_id, num_b_value1_rows, num_rows, n), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
    end
    
    if num_cols ~= num_b_value1_cols
      process_error_msg(sprintf('Scan ID: %s - Number of image cols (%d) for first b-value does not match number of image cols (%d) for b-value #%d', ...
                                scan_id, num_b_value1_cols, num_cols, n), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
    end
    
    if num_slices ~= num_b_value1_slices
      process_error_msg(sprintf('Scan ID: %s - Number of slices (%d) for first b-value does not match number of slices (%d) for b-value #%d', ...
                                scan_id, num_b_value1_slices, num_slices, n), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
    end
  end

  % Write series data to Matlab file
  msg = 'Writing Matlab data file...';

	if ~isempty(waitbar_handle)
	  waitbar(1, waitbar_handle, msg);
	else
	  disp(msg);
	end
	
  save(matlab_series_filepath, 'Data', 'Info', 'Acquisition_Times');
else
  process_error_msg(sprintf('Scan ID: %s - unable to find any valid DICOM files in selected series dirs.', scan_id), log_file, log_window_text);
	return;
end

ran_ok = true;
