
function ran_ok = DICOMAT_Create_Matlab_Generic_File(scan_id, scan_series_dirs, matlab_series_filepath, ...
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

% Loop over each series and read in the associated DICOM data
for n=1:length(scan_series_dirs)	
  % Read the DICOM files for this series into Matlab
  [Series_Data, Series_Info, Series_Acquisition_Times, warning_msgs] = DICOMAT_Load_DICOM_Series(scan_series_dirs(n), Series_Options.pixel_class, ...
  																																													 		 log_file, log_window_text, waitbar_handle);

  % Check if waitbar cancel button was pressed
	if check_if_waitbar_cancel_pressed(waitbar_handle)
  	return;
	end

  % Store returned variables in cell arrays
	if ~isempty(Series_Data)
  	if exist('Data', 'var')
    	idx = length(Data)+1;
    	Data(idx) = Series_Data;
  	else
    	Data = Series_Data;
  	end
		
  	if exist('Acquisition_Times', 'var')
    	idx = length(Acquisition_Times)+1;
    	Acquisition_Times(idx) = Series_Acquisition_Times;
  	else
    	Acquisition_Times = Series_Acquisition_Times;
  	end
  
  	if exist('Info', 'var')
    	idx = length(Info)+1;
    	Info(idx) = Series_Info;
  	else
    	Info = Series_Info;
  	end
  
  	if ~isempty(warning_msgs)
    	process_error_msg(warning_msgs, log_file, log_window_text);
  	end
	else
		Data = [];
	end
end

if ~isempty(Data)
  % Number of series
  num_series = length(Data);
  
  % Check that the dimensions of all the MR volumes are consistent
  [num_series1_rows, num_series1_cols, num_series1_slices] = size(Data{1});
  
  for n=2:num_series
    [num_rows, num_cols, num_slices] = size(Data{n});
    
    if num_rows ~= num_series1_rows
      process_error_msg(sprintf('Scan ID: %s - Number of image rows (%d) for first series does not match number of image rows (%d) for series %d', ...
                                scan_id, num_series1_rows, num_rows, n), log_file, log_window_text);
    end
    
    if num_cols ~= num_series1_cols
      process_error_msg(sprintf('Scan ID: %s - Number of image cols (%d) for first series does not match number of image cols (%d) for series %d', ...
                                scan_id, num_series1_cols, num_cols, n), log_file, log_window_text);
    end
    
    if num_slices ~= num_series1_slices
      process_error_msg(sprintf('Scan ID: %s - Number of slices (%d) for first series does not match number of slices (%d) for series %d', ...
                                scan_id, num_series1_slices, num_slices, n), log_file, log_window_text);
    end
  end

  % Write series data to Matlab file
  msg = 'Writing Matlab data file...';

	if ~isempty(waitbar_handle)
	  waitbar(1, waitbar_handle, msg);
	else
	  disp(msg);
	end

  % Write series data to Matlab file
  save(matlab_series_filepath, 'Data', 'Info', 'Acquisition_Times');
else
  process_error_msg(sprintf('Scan ID: %s - unable to find any valid DICOM files in selected series dirs.', scan_id), log_file, log_window_text);
	return;
end

ran_ok = true;
