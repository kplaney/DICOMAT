
function [Data, Info, Acquisition_Times, warning_msgs] = DICOMAT_Load_BOLD_MRI_Series_Files(BOLD_series_dirs, pixel_class, ...
																																												log_file, log_window_text, waitbar_handle)

Data = []; Info = []; Acquisition_Times = []; warning_msgs = [];

update_waitbar(0, waitbar_handle, 'Reading in DICOM files for BOLD scan...');

% Read in all BOLD data for the  given series dirs
[DICOM_files, Slice_Info, warning_msgs] = DICOMAT_Get_DICOM_Series_Metadata(BOLD_series_dirs, waitbar_handle);

% Check if waitbar cancel button was pressed
if check_if_waitbar_cancel_pressed(waitbar_handle)
  return;
end

% Check that we have some DICOM files for this series
if length(DICOM_files) == 0
  % Return if we didn't find any DICOM files in the given BOLD series directories
  warning_msgs{length(warning_msgs)+1} = sprintf('%s: No DICOM files returned from BOLD series dirs', mfilename);
  return;
end

update_waitbar(0, waitbar_handle, 'Sorting DICOM files for BOLD scan...');

% Extract echo times
TEs = [Slice_Info.EchoTime];

% Check that number of TEs we've extracted matches the number of slices (this checks for empty TE values)
if length(TEs) ~= length(Slice_Info) 
  warning_msgs{length(warning_msgs)+1} = sprintf('%s: problem - some Echo Times in DICOM header info are empty...', mfilename);
  return;
end

% First get a list of the unique TE values for the scan
unique_TEs = unique(TEs);
num_unique_TEs = length(unique_TEs);

num_DICOM_files_per_TE = zeros(1,num_unique_TEs);

% Loop over unique TEs
for j=1:num_unique_TEs
  TE = unique_TEs(j);

  % Check if waitbar cancel button is pressed
  if check_if_waitbar_cancel_pressed(waitbar_handle)
    % Clear variables and return
    Data = []; Acquisition_Times = []; Info = [];
    warning_msgs = sprintf('%s: Cancel button pressed', mfilename);
    return;
  else
    update_waitbar(j / num_unique_TEs, waitbar_handle, sprintf('Processing DICOM files for TE value %d of %d', j, num_unique_TEs));
  end
  
  % Get an index vector for all DICOM files corresponding to this TE
  TE_idx = find(TEs == TE);
  
  % Get the DICOM files and Slice Info for this TE
  DICOM_files_for_this_TE = DICOM_files(TE_idx);
  Slice_Info_for_this_TE = Slice_Info(TE_idx);
  num_DICOM_files_for_this_TE = length(DICOM_files_for_this_TE);
  
  % Now sort according to slice position
  sort_idx = DICOMAT_Get_Sort_Index_By_Slice_Position(Slice_Info_for_this_TE);
  DICOM_files_for_this_TE = DICOM_files_for_this_TE(sort_idx);
  Slice_Info_for_this_TE = Slice_Info_for_this_TE(sort_idx);
  
  % Loop and read in DICOM image data
  for n=1:num_DICOM_files_for_this_TE
    % Read in DICOM data and header info
    slice_data = dicomread(DICOM_files_for_this_TE{n});
    
    % Pre-allocate the memory for the MRI image data
    if n==1
      Data_for_this_TE = zeros(size(slice_data,1), size(slice_data,2), num_DICOM_files_for_this_TE, pixel_class);
    end
  
    % Store MRI image data for this slice
    Data_for_this_TE(:,:,n) = cast(slice_data, pixel_class);
  end
  
  Acquisition_Times{length(Acquisition_Times)+1} = sprintf('%s:%s:%s', ...
                                                           Slice_Info_for_this_TE(1).AcquisitionTime(1:2), ...
                                                           Slice_Info_for_this_TE(1).AcquisitionTime(3:4), ...
                                                           Slice_Info_for_this_TE(1).AcquisitionTime(5:6));
  
  % Store MRI data for this TE in cell array
  Data{length(Data)+1} = Data_for_this_TE;
  
  % Store Info for this TE in cell array
  Info{length(Info)+1} = Slice_Info_for_this_TE;

  % Store the number of DICOM files we read in for this TE
  num_DICOM_files_per_TE(j) = num_DICOM_files_for_this_TE;
end


% Display the unique acquisition times for the BOLD scan
if length(unique(Acquisition_Times)) == 1
  disp(sprintf('  Acquisition time for BOLD scan: %s', Acquisition_Times{1}));
else
  disp(sprintf('  Acquisition times for BOLD scan:'));
  disp(unique(Acquisition_Times));
end

% Finally check that the number of DICOM files is consistent for each TE
if length(unique(num_DICOM_files_per_TE)) > 1
  warning_msgs{length(warning_msgs)+1} = 'Number of DICOM files is not the same for each TE:';
  
  for j=1:num_unique_TEs
     warning_msgs{length(warning_msgs)+1} = sprintf('TE = %1.2f: number of DICOM files = %3d', unique_TEs(j), num_DICOM_files_per_TE(j));
  end
end
