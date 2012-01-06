
function [formatted_series_dirpaths, annotated_series_dirpaths] = DICOMAT_Get_Series_Dirpaths(scan_dirpaths, varargin)

dir_separator = [];
	
% Process optional arguments
if length(varargin)
	if isstr(varargin{1})
		dir_separator = varargin{1};
	else
		disp(sprintf('%s: optional dir_separator should be a text string', mfilename));
	end
end

% Convert scan dirpaths to a cell array of strings if not already
if ~iscellstr(scan_dirpaths)
	scan_dirpaths = {scan_dirpaths};
end

% Initialise
formatted_series_dirpaths{1} = dir_separator;
annotated_series_dirpaths{1} = dir_separator;

% Create a waitbar
waitbar_handle = create_waitbar('Building list of DICOM series directories...');

% Loop over scan dirpaths
N = length(scan_dirpaths);

for n=1:N
	if check_if_waitbar_cancel_pressed(waitbar_handle)
		delete(waitbar_handle);
		return;
	end
	
	update_waitbar((n-1)/N, waitbar_handle, strrep(scan_dirpaths{n}, '_', '\_'));
	
	% Get a list of subdirectories under this scan dir
  series_dirpaths = get_recursive_dirlist(scan_dirpaths{n}, 1);

	if ~isempty(series_dirpaths)
		% Sort based on DICOM series number
		[sorted_series_dirpaths, sort_idx, series_nums, num_files] = DICOMAT_Sort_Series_Dirs_by_Series_Num(series_dirpaths);		
		offset = length(formatted_series_dirpaths);
		
		for k=1:length(sorted_series_dirpaths)
			formatted_series_dirpaths{offset+k,1} = sorted_series_dirpaths{k};
			annotated_series_dirpaths{offset+k,1} = sprintf('%s    [%d files]', sorted_series_dirpaths{k}, num_files(k));
		end
		
  	formatted_series_dirpaths = [formatted_series_dirpaths; dir_separator];
	  annotated_series_dirpaths = [annotated_series_dirpaths; dir_separator];
	end
end

delete(waitbar_handle);
