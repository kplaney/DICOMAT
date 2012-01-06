
function [sort_idx, warning_msgs] = DICOMAT_Get_Sort_Index_for_Dynamic_Acquisition(Info)

sort_idx = []; warning_msgs = [];

% Extract series and instance numbers, and acquisition and content times (as cell array of strings)
series_nums = [Info.SeriesNumber];
instance_nums = [Info.InstanceNumber];
acq_times = {Info.AcquisitionTime};
con_times = {Info.ContentTime};

num_slices = length(Info);

% Check if we have a missing series number for any of the slices
if length(series_nums) ~= num_slices
	% Missing series numbers in the DICOM headers is a series problem - so we can't proceed
 	msg = sprintf('%s: problem - some Series Numbers in DICOM metadata are empty. Unable to sort dynamic acquisition.', mfilename);
  warning_msgs = update_messages_array(warning_msgs, msg);
  return;
end

% Check if we have a missing instance number for any of the slices
if length(instance_nums) ~= num_slices
	% Missing or empty instance numbers is more common, we can still proceed and try to sort on another field
	msg = sprintf('%s: warning - some Instance Numbers in DICOM metadata are empty...', mfilename);
  warning_msgs = update_messages_array(warning_msgs, msg);
end

% If the instance numbers are unique (should be according to DICOM standard) and
% we have one for every slice, then use these values as the secondary sort key
if length(unique(instance_nums)) == num_slices
	secondary_sort_values = instance_nums;
else
	% Otherwise check if we have enough AcquisitionTimes or ContentTimes to sort on
	if length(acq_times) == num_slices
		msg = sprintf('%s: warning - DICOM InstanceNumbers are missing or non-unique. Sorting on AcquisitionTime field.', mfilename);
		secondary_sort_values = acq_times;
	elseif length(con_times) == num_slices
		msg = sprintf('%s: warning - DICOM InstanceNumbers are missing or non-unique. Sorting on ContentTime field.', mfilename);
		secondary_sort_values = con_times;
	else
		msg = sprintf('%s: problem - unable to sort on either the DICOM InstanceNumber, AcquisitionTime or ContentTime fields...', mfilename);
	  return;
	end
	
	warning_msgs = update_messages_array(warning_msgs, msg);
end

% Now compute the sort index:

% First get a list of the unique series numbers for the dynamic acquisition - this is the primary sort key
unique_series = unique(series_nums);

% Initialise sort index vector
sort_idx = [];

% Loop over unique series
for j=1:length(unique_series)
  series = unique_series(j);
  
  % Get an index vector for all the slices corresponding to this series
  this_series_idx = find(series_nums == series);
  
  % Now "sub sort" the slices corresponding to this series using the secondary sort key (determined above)
  [tmp, secondary_sort_idx] = sort(secondary_sort_values(this_series_idx));
  
  % Now update the sort index vector we are computing
  sort_idx = [sort_idx this_series_idx(secondary_sort_idx)];
end
