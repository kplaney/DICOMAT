
function [Data, Info, Acquisition_Time, warning_msgs] = DICOMAT_Load_DICOM_Series(series_dir, pixel_class, log_file, log_window_text, waitbar_handle)

Data = []; Info = []; Acquisition_Time = []; warning_msgs = [];

% Read in data for this series
msg = 'Reading in series DICOM files...';

% First get the metadata for this series
[DICOM_files, Info, warning_msgs] = DICOMAT_Get_DICOM_Series_Metadata(series_dir, waitbar_handle);
num_DICOM_files = length(DICOM_files);

% Check if waitbar cancel button was pressed
if check_if_waitbar_cancel_pressed(waitbar_handle)
  return;
end

% Check that we have some DICOM files for this series
if num_DICOM_files == 0
  % Return if we didn't find any DICOM files in the given dynamic acquisition series directories
  warning_msgs{length(warning_msgs)+1} = sprintf('%s: No DICOM files returned for series dir: %s', mfilename, series_dir);
  return;
end
  
update_waitbar(1, waitbar_handle, 'Sorting series DICOM files...');

% Sort DICOM files by slice position
sort_idx = DICOMAT_Get_Sort_Index_By_Slice_Position(Info);
DICOM_files = DICOM_files(sort_idx);
Info = Info(sort_idx);

% Loop over DICOM series files
for n=1:num_DICOM_files
  % Read in DICOM data and header info
  slice_data = dicomread(DICOM_files{n});

  % Pre-allocate the memory for the image data
  if n==1
    clear Data;
    Data = zeros(size(slice_data,1), size(slice_data,2), num_DICOM_files, pixel_class);
  end
  
  % Store image data for this slice
  Data(:,:,n) = cast(slice_data, pixel_class);
end

Acquisition_Time = sprintf('%s:%s:%s', Info(1).AcquisitionTime(1:2), Info(1).AcquisitionTime(3:4), Info(1).AcquisitionTime(5:6));

% Return all variables as cell arrays to be consistent with other functions
Data = {Data};
Info = {Info};
Acquisition_Time = {Acquisition_Time};
