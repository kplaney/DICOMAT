
function [sorted_series_dirpaths, sort_idx, series_nums, num_files] = DICOMAT_Sort_Series_Dirs_by_Series_Num(series_dirpaths)

if ~license('test','image_toolbox')
	disp(sprintf('%s requires a license for the image processing toolbox. Cannot call dicominfo', mfilename));
	got_license = false;
else
	got_license = true;
end
	
if ~iscellstr(series_dirpaths)
	series_dirpaths = {series_dirpaths};
end

num_series_dirs = length(series_dirpaths);
series_nums = nan(1, num_series_dirs);
num_files = nan(1, num_series_dirs);

for series_dir=1:length(series_dirpaths)
	series_dir_struct = dir(series_dirpaths{series_dir});
	num_files(series_dir) = sum(~[series_dir_struct.isdir]);

	if got_license
		for n=1:length(series_dir_struct)
			if ~strcmp(series_dir_struct(n).name, '.') && ~strcmp(series_dir_struct(n).name, '..') && ~series_dir_struct(n).isdir
				filename = fullfile(series_dirpaths{series_dir}, series_dir_struct(n).name);
				clear info;
				try
					info = dicominfo(filename);
								
					if isfield(info, 'SeriesNumber')
						series_nums(series_dir) = info.SeriesNumber;
						break;
					end
				end
			end
		end
		
		if isnan(series_nums(series_dir))
			disp(sprintf('%s: Unable to find a valid DICOM file in series directory: %s', mfilename, series_dirpaths{series_dir}));
		end		
	end
end

% Series numbers for some diagnostic DCE-MRI scans can be in the thousands (e.g. 1500, 1501, 1502 etc)
% Therefore we divide these values by 100 so that a sort of the series numbers gives the correct series order
if got_license
	idx = find(series_nums>=100);
	series_nums(idx) = series_nums(idx)/100;

	[series_nums, sort_idx] = sort(series_nums);
	
	sorted_series_dirpaths = series_dirpaths(sort_idx);
	series_nums = series_nums(sort_idx);
	num_files = num_files(sort_idx);
else
	sorted_series_dirpaths = series_dirpaths;
	sort_idx = [1:length(series_dirpaths)];
end
