
function DICOMAT_Reset_DICOM_Metadata(DICOM_field_updates, matlab_series_filepath, log_file, log_window_text)

load(matlab_series_filepath, 'Info');

% Check that Info exists in the given matlab file
if ~exist('Info', 'var')
	process_error_msg(sprintf('Unable to reset DICOM fields. No Info variable in matlab file: %s', matlab_series_fileapth), ...
										log_file, log_window_text);
	return;
else
	% Convert to a cell array - makes subsequent coding easier
	if ~iscell(Info)
		Info = {Info};
	end
	
	for k=1:length(Info)
		for d=1:size(DICOM_field_updates)
			DICOM_field = DICOM_field_updates{d,1};
			new_value = DICOM_field_updates{d,2};
			
			[Info{k}.(DICOM_field)] = deal(new_value);
		end
	end
end

% If a singleton cell array then convert back to struct array form
if length(Info) == 1
	Info = Info{1};
end

% Save updated Info to file
save(matlab_series_filepath, 'Info', '-append');
