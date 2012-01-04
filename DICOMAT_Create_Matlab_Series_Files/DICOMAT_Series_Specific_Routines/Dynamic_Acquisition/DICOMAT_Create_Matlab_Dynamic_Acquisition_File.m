
function ran_ok = DICOMAT_Create_Matlab_Dynamic_Acquisition_File(scan_id, scan_series_dirs, matlab_series_filepath, ...
																																 Series_Options, log_file, log_window_text, varargin);

ran_ok = false;

% Check that series options struct contains the required fields
if ~isfield(Series_Options, 'num_pre_injection_vols')
  process_error_msg(sprintf('Scan ID: %s - num_pre_injection_vols field not defined in Series options struct', scan_id), log_file, log_window_text);
  return;
end

if ~isfield(Series_Options, 'temporal_res')
  process_error_msg(sprintf('Scan ID: %s - temporal_res field not defined in Series options struct', scan_id), log_file, log_window_text);
  return;
end

if ~isfield(Series_Options, 'pixel_class')
  process_error_msg(sprintf('Scan ID: %s - pixel_class field not defined in Series options struct', scan_id), log_file, log_window_text);
  return;
end

% Set up waitbar handle
if length(varargin)
  waitbar_handle = varargin{1};
else
  waitbar_handle = [];
end

% Read the dynamic acquisition DICOM files into Matlab
[Data, Info, Acquisition_Times, sample_times, warning_msgs] = DICOMAT_Load_Dynamic_Acquisition_Series_Files(scan_series_dirs, Series_Options.pixel_class, ...
																																																						Series_Options.series_type, log_file, ...
																																																						log_window_text, waitbar_handle);

% Process any warning messages
if ~isempty(warning_msgs)
  process_error_msg(warning_msgs, log_file, log_window_text);
end

if ~isempty(Data)
  % Number of dynamic volumes / time points
  num_vols = length(Data);

  % Check that the dimensions of all the dynamic volumes are consistent
  [first_volume_num_rows, first_volume_num_cols, first_volume_num_slices] = size(Data{1});
  
  for v=2:num_vols
    [num_rows, num_cols, num_slices] = size(Data{v});
    num_volume_Info = length(Info{v});
    
    if num_rows ~= first_volume_num_rows
      process_error_msg(sprintf('Scan ID: %s - Number of image rows (%d) for first volume does not match number of image rows (%d) for volume %d', ...
                                scan_id, first_volume_num_rows, num_rows, v), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
      return;
    end
    
    if num_cols ~= first_volume_num_cols
      process_error_msg(sprintf('Scan ID: %s - Number of image cols (%d) for first volume does not match number of image cols (%d) for volume %d', ...
                                scan_id, first_volume_num_cols, num_cols, v), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
      return;
    end
    
    if num_slices ~= first_volume_num_slices
      process_error_msg(sprintf('Scan ID: %s - Number of slices (%d) for first volume does not match number of slices (%d) for volume %d', ...
                                scan_id, first_volume_num_slices, num_slices, v), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
      return;
    end
  
    % Check that size of the Info struct array for this volume matches the number of slices
    if num_volume_Info ~= first_volume_num_slices
      process_error_msg(sprintf('Scan ID: %s - Number of slices (%d) for first volume does not match the number of Info records (%d) for volume %d', ...
                                scan_id, first_volume_num_slices, num_volume_Info, v), log_file, log_window_text);
			process_error_msg({'DICOM series dirs:' scan_series_dirs{:}}, log_file, log_window_text);
      return;
    end
  end
  
  if ~isempty(Series_Options.temporal_res)
    % Reset the sample times according to the user-defined temporal resolution
    temporal_res_secs = Series_Options.temporal_res;
    temporal_res_mins = temporal_res_secs/60;
    sample_times = [0:temporal_res_mins:(num_vols-1)*temporal_res_mins];
  else
    % Check that the length of sample_times matches the number of dynamic volumes
    num_time_points = length(sample_times);
    
    if num_time_points ~= num_vols
      process_error_msg(sprintf('Scan ID: %s - Number of Acquisition/Sample Times does not match the number of dynamic volumes'), ...
                        scan_id, log_file, log_window_text);
    end
  end
  
  % Write dynamic series data to Matlab file
  msg = 'Writing Matlab data file...';

	if ~isempty(waitbar_handle)
	  waitbar(1, waitbar_handle, msg);
	else
	  disp(msg);
	end
	
  save(matlab_series_filepath, 'Data', 'Info', 'Acquisition_Times', 'sample_times');

 % Create a binary vector indicating which dynamic volumes are pre-injection
	if ~isempty(Series_Options.num_pre_injection_vols)
  	is_pre_injection_volume = zeros(1, num_vols);
  	is_pre_injection_volume(1:Series_Options.num_pre_injection_vols) = 1;

		save(matlab_series_filepath, '-append', 'is_pre_injection_volume');
	end
else
  process_error_msg(sprintf('Scan ID: %s - Data cell array for dynamic acquisition is empty, not writing Matlab file.', scan_id), log_file, log_window_text);
	return;
end

ran_ok = true;
