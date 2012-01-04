
function [Data, Info, Acquisition_Times, sample_times, warning_msgs] = DICOMAT_Load_Dynamic_Acquisition_Series_Files(series_dirs, pixel_class, series_type, ...
																																																		 		 						 log_file, log_window_text, waitbar_handle)

Data = []; Info = []; Acquisition_Times = []; sample_times = []; warning_msgs = [];

Acquisition_Time_format = 'HH:MM:SS';

% Read in all dynamic data for this scan
msg = sprintf('Reading in DICOM files for %s scan...', series_type);

if ~isempty(waitbar_handle)
  waitbar(0, waitbar_handle, msg);
else
  disp(msg);
end

% Read in all data for this series
[DICOM_files, Slice_Info, warning_msgs] = DICOMAT_Get_DICOM_Series_Metadata(series_dirs, waitbar_handle);

% Check if waitbar cancel button was pressed
if check_if_waitbar_cancel_pressed(waitbar_handle)
  return;
end

% Check that we have some DICOM files for this series
if length(DICOM_files) == 0
  % Return if we didn't find any DICOM files in the given series directories
  warning_msgs{length(warning_msgs)+1} = sprintf('%s: No DICOM files returned from %s series dirs', mfilename, series_type);
  return;
end

% Update waitbar or display the msg
msg = sprintf('Sorting DICOM files for %s scan...', series_type);

if ~isempty(waitbar_handle)
  waitbar(0, waitbar_handle, msg);
else
  disp(msg);
end

% Sort DICOM files and Info according to series and instance numbers
[sort_idx, error_msg] = DICOMAT_Get_Sort_Index_By_Series_and_Instance(Slice_Info);

if isempty(sort_idx)
	disp(sprintf('%s: problem sorting DICOM files by series and instance', mfilename));
	warning_msgs{length(warning_msgs)+1} = error_msg;
	return;
else
	DICOM_files = DICOM_files(sort_idx);
	Slice_Info = Slice_Info(sort_idx);
end

% Extract slice acquisition times and locations (rounded to nearest decimal place)
instance_nums = [Slice_Info.InstanceNumber];
acquisition_times = {Slice_Info.AcquisitionTime};
slice_locations = cellfun(@(x) round((x*10))/10, {Slice_Info.SliceLocation});

% Initialise variables
start_new_volume = false;
slice = 1;
volume_data = [];
volume_acq_times = [];
relative_acq_times = [];

% Loop over all sorted DICOM files for the dynamic acquisition
for k=1:length(DICOM_files)
  msg = sprintf('Processing DICOM file %d of %d', k, length(DICOM_files));
  
  % Check if waitbar cancel button is pressed
  if check_if_waitbar_cancel_pressed(waitbar_handle)
    % Clear variables and return
    Data = []; Acquisition_Times = []; sample_times = []; Info = [];
    warning_msgs = sprintf('%s: Cancel button pressed', mfilename);
    return;
  else
    if ~isempty(waitbar_handle)
      % Update waitbar
      waitbar_fraction = k / length(DICOM_files);
      waitbar(waitbar_fraction, waitbar_handle, msg);
    else
      disp(msg);
    end
  end
  
  % Check if we have missing slice data (i.e. the instance numbers are not contiguous)
  if k > 1 && (instance_nums(k) - instance_nums(k-1) > 1)
    process_error_msg(sprintf('Missing DICOM file for slice %d [this instance num: %d, prev instance num: %d]', slice, instance_nums(k), instance_nums(k-1)), ...
                      log_file, log_window_text);
    num_volumes_processed = length(Data);
    
    % See if we can replace the missing slice with the same slice from the previous time point
    if num_volumes_processed == 0
      process_error_msg(sprintf('Cannot substitute previous time point data since this is the scan for the first volume...'), log_file, log_window_text);
    else
      process_error_msg(sprintf('Substituting image data for slice %d from volume for previous time point', slice), log_file, log_window_text);
      
      prev_vol_data = Data{num_volumes_processed};
      volume_data(:,:,slice) = prev_vol_data(:,:,slice);
    end
    
    % If we have missing data then set the Info to empty for this slice
    % (even if we have subsituted in data from a previous slice)
    volume_info(slice).Scan_Date = []; % NB: Just setting one field will initialise all other fields to empty values
  else
    % Read in DICOM data and header info
    clear slice_data slice_info;
    slice_data = dicomread(DICOM_files{k});
    
    % Store image data for this slice
    volume_data(:,:,slice) = cast(slice_data, pixel_class);
    
    % Store Info for this slice
    volume_info(slice) = Slice_Info(k);
    
    % Store acquisition time in Matlab date num format
    volume_acq_times(slice) = datenum(acquisition_times{k}, 'HHMMSS');
  end
  
  % Determine if we need to start a new volume for the next slice:
  % NB - we need to look at 3 successive slice locations to decide
  % this since the acquisition can be from -ve to +ve or vice versa
  if slice >= 2 && k < length(DICOM_files)
    % Get the forward and reverse slice location diffs
    forward_slice_diff = slice_locations(k+1) - slice_locations(k);
    reverse_slice_diff = slice_locations(k) - slice_locations(k-1);
    
    % We start a new volume if either of the following cases are true:
    % 1.) The slice locations were going in the +ve direction (reverse_slice_diff > 0)
    % but have just changed to the -ve direction (forward_slice_diff < 0)
    % 2.) The slice locations were going in the -ve direction (reverse_slice_diff < 0)
    % but have just changed to the +ve direction (forward_slice_diff > 0)
    if forward_slice_diff < 0 && reverse_slice_diff > 0
      start_new_volume = true;
    elseif forward_slice_diff > 0 && reverse_slice_diff < 0
      start_new_volume = true;
    else
      start_new_volume = false;
    end
  end
  
  % Start a new volume
  if start_new_volume || k == length(DICOM_files)
    % Reset the new volume flag
    start_new_volume = false;
    
    % Display the acquisition time range for the volume just processed
    %disp(sprintf('  Acquisition time range: %s to %s', datestr(volume_acq_times(1), Acquisition_Time_format), ...
		%																										datestr(volume_acq_times(end), Acquisition_Time_format)));
    
    % Store volume data in Data cell array
    Data{length(Data)+1} = volume_data;
    
    % Store volume Info in Info cell array
    Info{length(Info)+1} = volume_info;
    
    % Computed a weighted mean acquisition time for the slices in this volume
    unique_acq_times = unique(volume_acq_times);
    weighted_mean_acq_time = 0;
    
    for j=1:length(unique_acq_times)
      frac = sum(unique_acq_times(j)==volume_acq_times) / length(volume_acq_times);
      weighted_mean_acq_time = weighted_mean_acq_time + unique_acq_times(j)*frac;
    end
    
    % Store the weighted mean acquisition time for this volume as a text string
    Acquisition_Times{1,length(Acquisition_Times)+1} = datestr(weighted_mean_acq_time, Acquisition_Time_format);
    
    % Reset the slice index
    slice = 1;
    
    % Reset variables
    clear volume_data volume_info volume_acq_times;
  else
    % Increment slice counter
    slice = slice + 1;
  end
end


keyboard


% Create a sample times numeric vector in mins.frac_of_mins format with
% all times relative to the sample time for the first dynamic volume
acq_datenums = datenum(Acquisition_Times, Acquisition_Time_format);
acq_mins = str2num(datestr(acq_datenums, 'MM'));
acq_secs = str2num(datestr(acq_datenums, 'SS'));
sample_times = acq_mins + (acq_secs/60);
sample_times = sample_times - sample_times(1);
sample_times = sample_times(:)';  % convert to row vector
