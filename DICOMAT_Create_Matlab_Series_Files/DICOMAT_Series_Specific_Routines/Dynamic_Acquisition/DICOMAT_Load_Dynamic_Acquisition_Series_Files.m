
function [Data, Info, Acquisition_Times, sample_times, warning_msgs] = DICOMAT_Load_Dynamic_Acquisition_Series_Files(series_dirs, pixel_class, series_type, ...
																																																		 		 						 log_file, log_window_text, waitbar_handle)

Data = []; Info = []; Acquisition_Times = []; sample_times = []; warning_msgs = [];

update_waitbar(0, waitbar_handle, sprintf('Reading in DICOM files for %s scan...', series_type));

% Read in all dynamic data for the given series dirs
[DICOM_files, Slice_Info, msgs] = DICOMAT_Get_DICOM_Series_Metadata(series_dirs, waitbar_handle);
warning_msgs = update_messages_array(warning_msgs, msgs);

% Check that we have some DICOM files for this series
num_DICOM_files = length(DICOM_files);

if num_DICOM_files == 0
  % Return if we didn't find any DICOM files in the given series directories
  warning_msgs = update_messages_array(warning_msgs, sprintf('%s: No DICOM files returned from %s series dirs', mfilename, series_type));
  return;
end

% Sort DICOM files and Info for the dynamic acquisition
update_waitbar(0, waitbar_handle, sprintf('Sorting DICOM files for %s scan...', series_type));
[sort_idx, msgs] = DICOMAT_Get_Sort_Index_for_Dynamic_Acquisition(Slice_Info);
warning_msgs = update_messages_array(warning_msgs, msgs);
	
if isempty(sort_idx)
	warning_msgs = update_messages_array(warning_msgs, sprintf('%s: problem sorting DICOM files by series and instance number', mfilename));
	return;
else
	DICOM_files = DICOM_files(sort_idx);
	Slice_Info = Slice_Info(sort_idx);
end

% Decide which slices belong to which dynamic volumes - return as a cell array of slice indices for each volume
[volume_slices_cell, msgs] = DICOMAT_Assign_Slices_to_Dynamic_Volumes(Slice_Info);
warning_msgs = update_messages_array(warning_msgs, msgs);

% Now read in the image data for each volume
num_files_read = 0;

for v=1:length(volume_slices_cell)
	slices_idx = volume_slices_cell{v};  % vector slice indices for this volume
	
	% Loop over slices for each volume
	for k=1:length(slices_idx)
		% Check if waitbar cancel button is pressed
  	if check_if_waitbar_cancel_pressed(waitbar_handle)
    	% Clear variables and return
    	Data = []; Acquisition_Times = []; sample_times = []; Info = [];
    	warning_msgs = update_messages_array(warning_msgs, sprintf('%s: cancel button pressed', mfilename));
    	return;
  	else
    	update_waitbar(num_files_read/num_DICOM_files, waitbar_handle, sprintf('Processing DICOM file %d of %d', ...
    								 num_files_read, num_DICOM_files));
  	end

		% Read in DICOM data for this image
		clear slice_data;
  	slice_data = dicomread(DICOM_files{slices_idx(k)});
		num_files_read = num_files_read + 1;
		
  	% Store image data for this slice
  	volume_data(:,:,k) = cast(slice_data, pixel_class);

  	% Store meta data for this slice
  	volume_info(k) = Slice_Info(slices_idx(k));
	end

	% Store volume data in Data cell array
  Data{v} = volume_data;
  
  % Store volume Info in Info cell array
  Info{v} = volume_info;
  
  % Computed a weighted mean acquisition time for the slices in this volume
	volume_acq_times = datenum({volume_info.AcquisitionTime}, 'HHMMSS');
  [unique_acq_times, tmp, occurences] = unique(volume_acq_times);
	counts_vec = accumarray(occurences(:),1);
	weighted_mean_acq_time = unique_acq_times(:).*counts_vec/sum(counts_vec);
  
  % Store the weighted mean acquisition time for this volume as a text string
  Acquisition_Times{1,v} = datestr(weighted_mean_acq_time, 'HH:MM:SS');
  
  % Reset variables
  clear volume_data volume_info;
end

% Create a sample times numeric vector in mins.frac_of_mins format with
% all times relative to the sample time for the first dynamic volume
acq_datenums = datenum(Acquisition_Times, 'HH:MM:SS');
acq_mins = str2num(datestr(acq_datenums, 'MM'));
acq_secs = str2num(datestr(acq_datenums, 'SS'));
sample_times = acq_mins + (acq_secs/60);
sample_times = sample_times - sample_times(1);
sample_times = sample_times(:)';  % convert to row vector
