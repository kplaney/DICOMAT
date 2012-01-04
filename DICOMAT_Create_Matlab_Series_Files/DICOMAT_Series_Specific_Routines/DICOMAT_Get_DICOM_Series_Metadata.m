
function [DICOM_files, Slice_Info, warning_msgs] = DICOMAT_Get_DICOM_Series_Metadata(DICOM_series_dirs, waitbar_handle)

DICOM_files = []; Slice_Info = []; warning_msgs = [];

% Check that we have a license for the image processing toolbox - needed for dicominfo
if ~license('test','image_toolbox')
	error(sprintf('%s requires a license for the image processing toolbox (for dicomread/dicominfo functions)...', mfilename));
	return;
end

if nargin == 1
	waitbar_handle = [];
end

if ~iscellstr(DICOM_series_dirs)
  DICOM_series_dirs = {DICOM_series_dirs};
end

D = length(DICOM_series_dirs);
idx = 1;

for d=1:D
  dir_frac = 1/D;
  DICOM_series_dir = DICOM_series_dirs{d};
  DICOM_series_dir_struct = dir(DICOM_series_dir);
  
  N = length(DICOM_series_dir_struct);
  
  found_dicom_file = 0;
  
  for n=1:N
    if ~DICOM_series_dir_struct(n).isdir      
      % Check if waitbar cancel button was pressed
      if check_if_waitbar_cancel_pressed(waitbar_handle)
        % Clear variables and return
        DICOM_files = []; Slice_Info = []; warning_msgs = [];
        warning_msgs{length(warning_msgs)+1} = sprintf('%s: Cancel button pressed', mfilename);
        return;
      end
      
			filename = DICOM_series_dir_struct(n).name;
      filepath = fullfile(DICOM_series_dir, filename);

			% Get DICOM series name
      dirsep_idx = strfind(DICOM_series_dir,filesep);
      seriesname = DICOM_series_dir(dirsep_idx(end)+1:end);
              
      % Escape various problem characters which won't show up
      % properly when displaying seriesname/filename in GUI waitbar
      disp_filename = strcat(seriesname, filesep, filename);
      disp_filename = strrep(disp_filename, '_', '\_');
      
      msg = sprintf('Reading DICOM file:\n%s', disp_filename);
      
      if ~isempty(waitbar_handle)
        % Update waitbar
        waitbar_fraction = (d-1)*dir_frac + (n/N)*dir_frac;
        waitbar(waitbar_fraction, waitbar_handle, msg);
      end
      
			% See if we can get the dicominfo for this file
			try 
      	info = dicominfo(filepath);
      	found_dicom_file = true;
				valid_dicom_file = true;
			catch
				valid_dicom_file = false;
				warning_msgs{length(warning_msgs)+1} = sprintf('Invalid DICOM file: %s in DICOM series dir: %s', filename, seriesname);
			end
			
			if valid_dicom_file
      	DICOM_files{idx} = filepath;
      
      	% Store slice info
      	if idx == 1
        	% For the first element of the struct array we need to overwrite the existing empty initialisation
					Slice_Info = info;
      	else
					info_fieldnames = fieldnames(info);
					
					% Copy the struct data across manually to the struct array
					for k=1:length(info_fieldnames)
						Slice_Info(idx).(info_fieldnames{k}) = info.(info_fieldnames{k});
					end
      	end
      
      	idx = idx + 1;
			end
    end
  end
  
  if ~found_dicom_file
    warning_msgs{length(warning_msgs)+1} = sprintf('No DICOM files found in: %s', DICOM_series_dir);
  end
end

% Strip out any duplicated warning messages
warning_msgs = unique(warning_msgs);
