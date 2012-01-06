
function [volume_slices_cell, warning_msgs] = DICOMAT_Assign_Slices_to_Dynamic_Volumes(Slice_Info)

volume_slices_cell = []; warning_msgs = [];

% Now determine how many dynamic volumes we should have from the set of unique slice positions/orientations
all_IPP_IOPs = [[Slice_Info.ImagePositionPatient]' [Slice_Info.ImageOrientationPatient]'];
[unique_IPP_IOPs, tmp, occurences_idx] = unique(all_IPP_IOPs, 'rows');
num_of_slices_for_each_unique_IPP_IOP = accumarray(occurences_idx(:),1);
expected_num_of_volumes = max(num_of_slices_for_each_unique_IPP_IOP);

% Check if each unique IPP-IOP vector maps to the same number of slices in the dynamic data set
if ~all(num_of_slices_for_each_unique_IPP_IOP == expected_num_of_volumes)
	% If not then we either have missing or extra slices, so warn user...
	warning_msgs = update_messages_array(warning_msgs, sprintf('%s: missing or extra slices found', mfilename));
end

% Create a cell array containing the slice idx vector for each dynamic volume
volume_idx = 1; % volume we are currently working on
first_slice_idx = 1;  % index of the first slice for this volume
volume_slices_cell = [];
num_slices = size(all_IPP_IOPs,1);

% Loop over all slices
for slice_idx=1:num_slices
	% Check if the IPP-IOP vector for this slice is present in any of the previous slices for this volume
	[found_match, loc] = ismember(all_IPP_IOPs(slice_idx,:), all_IPP_IOPs(first_slice_idx:slice_idx-1,:), 'rows');
	
	if found_match
		if loc == 1 || loc ~= slice_idx-1
			% If it is present and the matching slice is either the first slice for this volume
			% or alternatively another slice in the volume but NOT the previous slice, then
			% the current slice must correspond to the first slice for the next volume.
			% Therefore store the slice indices for this volume and initiate a new volume
			volume_slices_cell{volume_idx} = [first_slice_idx:slice_idx-1];
			first_slice_idx = slice_idx;
			volume_idx = volume_idx + 1;
			
			if loc > 1
				% If the matching slice was not the first slice for the volume then
				% issue a warning message that we probably have missing slice data
				warning_msgs = update_messages_array(warning_msgs, sprintf('%s: probable missing slice data for volume %d', mfilename, volume_idx));
			end
		else
			% The current slice matches the previous slice - thus we have duplicated slice data
			% NB: the only case where this can occur legitimately is for a single slice dynamic acquisition however in
			% this case the matching location will also be equal to 1 and will be picked up by the first if statement
			warning_msgs = update_messages_array(warning_msgs, sprintf('%s: probable duplicated slice data for volume %d', mfilename, volume_idx));
		end
	end
	
	% For the final slice we need to explicitly store the slice indices for the last volume
	if slice_idx==num_slices
		volume_slices_cell{volume_idx} = [first_slice_idx:slice_idx];
	end
end

% Compute number of dynamic volumes we have
num_of_volumes = length(volume_slices_cell);

% Now check how many slices we have for each dynamic volume
num_of_slices_per_volume = cellfun(@(x) length(x), volume_slices_cell);
[unique_num_of_slices_per_volume, tmp, occurences_idx] = unique(num_of_slices_per_volume);
num_of_volumes_with_given_num_of_slices = accumarray(occurences_idx(:),1);

% If we don't have the same number of slices for each volume then warn the user
if length(unique_num_of_slices_per_volume) > 1
	warning_msgs = update_messages_array(warning_msgs, sprintf('%s: inconsistent number of slices across dynamic volumes', mfilename));
	
	for j=1:length(unique_num_of_slices_per_volume)
		if num_of_volumes_with_given_num_of_slices(j) == 1
			warning_msgs = update_messages_array(warning_msgs, sprintf('%s: %d volume has %d slices', mfilename, ...
																		  		 num_of_volumes_with_given_num_of_slices(j), ...
																		  		 unique_num_of_slices_per_volume(j)));
		else
			warning_msgs = update_messages_array(warning_msgs, sprintf('%s: %d volumes have %d slices', mfilename, ...
																					 num_of_volumes_with_given_num_of_slices(j), ...
																					 unique_num_of_slices_per_volume(j)));
		end
	end
end
