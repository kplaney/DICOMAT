
function [Data, Info, Acquisition_Times, warning_msgs] = DICOMAT_Load_DWI_MRI_Series_Files(DWI_series_dirs, pixel_class, ...
																																											log_file, log_window_text, waitbar_handle)

Data = []; Info = []; Acquisition_Times = []; warning_msgs = [];

% Read in all DWI data for this scan
msg = 'Reading in DICOM files for DWI scan...';

if ~isempty(waitbar_handle)
  waitbar(0, waitbar_handle, msg);
else
  disp(msg);
end

% Read in all data for this series
[DICOM_files, Slice_Info, warning_msgs] = DICOMAT_Get_DICOM_Series_Metadata(DWI_series_dirs, waitbar_handle);

% Check that we have some DICOM files for this series
if length(DICOM_files) == 0
  % Return if we didn't find any DICOM files in the given DWI series directories
  warning_msgs{length(warning_msgs)+1} = sprintf('%s: No DICOM files returned from DWI series dirs', mfilename);
  return;
end

% Extract b values depending on the scanner type
if isfield(Slice_Info, 'Private_0043_1039')
  % GE scanner
	for s=1:length(Slice_Info)
  	Slice_Info(s).b_value = Slice_Info(s).Private_0043_1039(1);
	end
elseif isfield(Slice_Info, 'Private_0019_100c')
  % Siemens scanner
	for s=1:length(Slice_Info)
  	Slice_Info(s).b_value = Slice_Info(s).Private_0019_100c(1);
	end
else
	warning_msgs{length(warning_msgs)+1} = sprintf('%s: problem - cannot find a DICOM field containing the b-values...', mfilename);
	return;
end

% Check that the number of b-values we extracted matches the number of slices (this checks for any empty values)
b_values = [Slice_Info.b_value];

if length(b_values) ~= length(Slice_Info) 
  warning_msgs{length(warning_msgs)+1} = sprintf('%s: problem - some b-values in DICOM header info are empty...', mfilename);
  return;
end

% First get a list of the unique b-values for the scan
unique_b_values = unique(b_values);
num_unique_b_values = length(unique_b_values);

num_DICOM_files_per_b_value = zeros(1,num_unique_b_values);

% Loop over unique b-values
for j=1:num_unique_b_values
  b_value = unique_b_values(j);
  msg = sprintf('Processing DICOM files for b-value %d of %d', j, num_unique_b_values);

  % Check if waitbar cancel button is pressed
  if check_if_waitbar_cancel_pressed(waitbar_handle)
    % Clear variables and return
    Data = []; Acquisition_Times = []; Info = [];
    warning_msgs = sprintf('%s: cancel button pressed', mfilename);
    return;
  else
    if ~isempty(waitbar_handle)
      % Update waitbar
      waitbar_fraction = j / num_unique_b_values;
      waitbar(waitbar_fraction, waitbar_handle, msg);
    else
      disp(msg);
    end
  end
  
  % Get an index vector for all DICOM files corresponding to this b-value
  b_value_idx = find(b_values == b_value);
  
  % Get the DICOM files and Slice Info for this b-value
  DICOM_files_for_this_b_value = DICOM_files(b_value_idx);
  Slice_Info_for_this_b_value = Slice_Info(b_value_idx);
  num_DICOM_files_for_this_b_value = length(DICOM_files_for_this_b_value);
  
  % Now sort according to slice position
  sort_idx = DICOMAT_Get_Sort_Index_By_Slice_Position(Slice_Info_for_this_b_value);
  DICOM_files_for_this_b_value = DICOM_files_for_this_b_value(sort_idx);
  Slice_Info_for_this_b_value = Slice_Info_for_this_b_value(sort_idx);
  
  % Loop and read in DICOM image data
  for n=1:num_DICOM_files_for_this_b_value
    % Read in DICOM data and header info
    slice_data = dicomread(DICOM_files_for_this_b_value{n});
    
    % Pre-allocate the memory for the MRI image data
    if n==1
      Data_for_this_b_value = zeros(size(slice_data,1), size(slice_data,2), num_DICOM_files_for_this_b_value, pixel_class);
    end
  
    % Store MRI image data for this slice
    Data_for_this_b_value(:,:,n) = cast(slice_data, pixel_class);
  end
  
  Acquisition_Times{length(Acquisition_Times)+1} = sprintf('%s:%s:%s', ...
                                                           Slice_Info_for_this_b_value(1).AcquisitionTime(1:2), ...
                                                           Slice_Info_for_this_b_value(1).AcquisitionTime(3:4), ...
                                                           Slice_Info_for_this_b_value(1).AcquisitionTime(5:6));
  
  % Store MRI data for this b-value in cell array
  Data{length(Data)+1} = Data_for_this_b_value;
  
  % Store Info for this b-value in cell array
  Info{length(Info)+1} = Slice_Info_for_this_b_value;

  % Store the number of DICOM files we read in for this b-value
  num_DICOM_files_per_b_value(j) = num_DICOM_files_for_this_b_value;
end


% Display the unique acquisition times for the DWI scan
if length(unique(Acquisition_Times)) == 1
  disp(sprintf('  Acquisition time for DWI scan: %s', Acquisition_Times{1}));
else
  disp(sprintf('  Acquisition times for DWI scan:'));
  disp(unique(Acquisition_Times));
end

% Finally check that the number of DICOM files is consistent for each b-value
if length(unique(num_DICOM_files_per_b_value)) > 1
  warning_msgs{length(warning_msgs)+1} = 'Number of DICOM files is not the same for each b-value:';
  
  for j=1:num_unique_b_values
     warning_msgs{length(warning_msgs)+1} = sprintf('b-value = %2.2f: number of DICOM files = %3d', unique_b_values(j), num_DICOM_files_per_b_value(j));
  end
end
