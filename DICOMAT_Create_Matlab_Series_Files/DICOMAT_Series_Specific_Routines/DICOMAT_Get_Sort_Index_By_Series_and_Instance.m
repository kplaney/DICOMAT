
%% This function will create a sort index for sorting DICOM files:
%% First according to the series number and secondly according to the instance number
%%
function [sort_idx, error_msg] = DICOMAT_Get_Sort_Index_By_Series_and_Instance(Info)

sort_idx = []; error_msg = [];
 
% Extract series and instance numbers
series_nums = [Info.SeriesNumber];
instance_nums = [Info.InstanceNumber];

if length(series_nums) ~= length(Info) 
  error_msg = sprintf('%s: problem - some Series Numbers in DICOM header info are empty...', mfilename);
  return;
end

if length(instance_nums) ~= length(Info) 
  error_msg = sprintf('%s: problem - some Instance Numbers in DICOM header info are empty...', mfilename);
  return;
end

% First get a list of the unique series numbers for the dynamic acquisition
unique_series = unique(series_nums);

% Initialise sort index vector
sort_idx = [];

% Loop over unique series
for j=1:length(unique_series)
  series = unique_series(j);
  
  % Get an index vector for all rows corresponding to this series
  this_series_idx = find(series_nums == series);
  
  % Sort the instance numbers corresponding to this series
  [tmp, instance_sort_idx] = sort(instance_nums(this_series_idx));
  
  % Now sort our index vector accorinding to
  % the sorted instance numbers for this series
  sort_idx = [sort_idx this_series_idx(instance_sort_idx)];
end
