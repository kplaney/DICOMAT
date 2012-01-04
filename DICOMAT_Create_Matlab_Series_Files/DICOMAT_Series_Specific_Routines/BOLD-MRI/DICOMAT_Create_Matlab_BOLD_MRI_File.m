
function ran_ok = DICOMAT_Create_Matlab_BOLD_MRI_File(scan_id, scan_series_dirs, matlab_series_filepath, ...
																				  				 Series_Options, log_file, log_window_text, varargin)

ran_ok = false;

% Set up waitbar handle
if length(varargin)
  waitbar_handle = varargin{1};
else
  waitbar_handle = [];
end

% Check that the pixel class is defined
if ~isfield(Series_Options, 'pixel_class')
  process_error_msg(sprintf('Scan ID: %s - pixel_class field not defined in Series options struct', scan_id), log_file, log_window_text);
  return;
end

% Read the BOLD DICOM files into Matlab
[Data, Info, Acquisition_Times, warning_msgs] = DICOMAT_Load_BOLD_MRI_Series_Files(scan_series_dirs, Series_Options.pixel_class, ...
																																							 log_file, log_window_text, waitbar_handle);

% Check if waitbar cancel button was pressed
if check_if_waitbar_cancel_pressed(waitbar_handle)
	return;
end

if ~isempty(warning_msgs)
  process_error_msg(warning_msgs, log_file, log_window_text);
end


if ~isempty(Data)
  % Number of BOLD "TE" volumes
  num_TEs = length(Data);
  
  % Check that the dimensions of all the MR volumes are consistent
  [num_TE1_rows, num_TE1_cols, num_TE1_slices] = size(Data{1});
  
  for n=2:num_TEs
    [num_rows, num_cols, num_slices] = size(Data{n});
    
    if num_rows ~= num_TE1_rows
      process_error_msg(sprintf('Scan ID: %s - Number of image rows (%d) for first TE does not match number of image rows (%d) for TE #%d', ...
                                scan_id, num_TE1_rows, num_rows, n), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
    end
    
    if num_cols ~= num_TE1_cols
      process_error_msg(sprintf('Scan ID: %s - Number of image cols (%d) for first TE does not match number of image cols (%d) for TE #%d', ...
                                scan_id, num_TE1_cols, num_cols, n), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
    end
    
    if num_slices ~= num_TE1_slices
      process_error_msg(sprintf('Scan ID: %s - Number of slices (%d) for first TE does not match number of slices (%d) for TE #%d', ...
                                scan_id, num_TE1_slices, num_slices, n), log_file, log_window_text);
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
