
function selection_idx = DICOMAT_Predefined_Series_Selection_Filters(filter_name, series_names)

selection_idx = [];

if isempty(filter_name) || isempty(series_names)
	return;
end

switch filter_name
	case 'Oxford Clinical DCE Sequence'
		logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'COR_3D_PRE_POST_GAD')), series_names); % Churchill clinical DCE series
		logical_idx2 = cellfun(@(series_name) ~isempty(strfind(series_name, 'COR_3D_FSPGR_PRE_POST_GA')), series_names); % JR clinical DCE series  
		selection_idx = find(logical_idx1 | logical_idx2);
		selection_idx = select_longest_contiguous_subseries(selection_idx);

	case 'Oxford Clinical VFA Sequence'
		logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'COR_3D_FLIP')), series_names); % Churchill variable flip series (clinical and research)
		logical_idx2 = cellfun(@(series_name) ~isempty(strfind(series_name, '3_COR_3D_FSPGR')), series_names); % JR variable flip series (clinical)
		logical_idx3 = cellfun(@(series_name) ~isempty(strfind(series_name, '17_COR_3D_FSPGR')), series_names); % JR variable flip series (clinical)  
		selection_idx = find(logical_idx1 | logical_idx2 | logical_idx3);

	case 'Oxford Avastin DCE Sequence'
		logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'SAGFAME')), series_names);  
		selection_idx = find(logical_idx1);

	case 'Oxford Avastin VFA Sequence'
		logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'SAG2DEG')), series_names);
		logical_idx2 = cellfun(@(series_name) ~isempty(strfind(series_name, 'SAG8DEG')), series_names);  
		selection_idx = find(logical_idx1 | logical_idx2);

	case 'Oxford Avastin BOLD Sequence'
		logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'BOLDTE')), series_names);  
		selection_idx = find(logical_idx1);

  case 'Oxford Avastin DWI Sequence'
    logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'B700')), series_names);
    logical_idx2 = cellfun(@(series_name) ~isempty(strfind(series_name, 'B100')), series_names);  
    selection_idx = find(logical_idx1 | logical_idx2);

  case 'MVH Avastin DCE Sequence'
    logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'T1DCE_VIBE_TRA_WIP_18DEG')), series_names);
    logical_idx2 = cellfun(@(series_name) ~isempty(strfind(series_name, 'DCE_T1_VIBE_21')), series_names);
    logical_idx3 = cellfun(@(series_name) ~isempty(strfind(series_name, 'T1_VIBE_TRA_DYNAMIC')), series_names);
    selection_idx = find(logical_idx1 | logical_idx2 | logical_idx3);

  case 'MVH Avastin VFA Sequence'
    logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'VIBE_TRA_WIP_2DEG')), series_names); % Original series
    logical_idx2 = cellfun(@(series_name) ~isempty(strfind(series_name, 'VIBE_TRA_WIP_8DEG')), series_names); % Original series
    logical_idx3 = cellfun(@(series_name) ~isempty(strfind(series_name, 'DCE_T1_VIBE_3')), series_names); % New series  
    logical_idx4 = cellfun(@(series_name) ~isempty(strfind(series_name, 'T1_VIBE_TRA_6DEG_DIVBY2')), series_names); % New series  
    selection_idx = find(logical_idx1 | logical_idx2 | logical_idx3 | logical_idx4);

  case 'MVH Avastin BOLD Sequence'
    logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'GRE_MBH_MULTIECHO_6SLICE')), series_names);  
    logical_idx2 = cellfun(@(series_name) ~isempty(strfind(series_name, 'T2_STAR_FL2D_TRA_BOLD')), series_names);
    selection_idx = find(logical_idx1 | logical_idx2);

  case 'MVH Avastin DWI Sequence'
   	logical_idx1 = cellfun(@(series_name) ~isempty(strfind(series_name, 'EP2D_DIFF_PRIMARY')) & isempty(strfind(series_name, '_ADC')), series_names);  
	  logical_idx2 = cellfun(@(series_name) ~isempty(strfind(series_name, 'EP2D_DIFF_3SCAN_TRACE')) & isempty(strfind(series_name, '_ADC')), series_names);  
	  selection_idx = find(logical_idx1 | logical_idx2);
	
	otherwise
		uiwait(errordlg(sprintf('Filter name: %s is not defined', filter_name), mfilename));
		return;
end


function longest_contiguous_subseries = select_longest_contiguous_subseries(series_selection_idx)

if ~isempty(series_selection_idx)
  % Get a cell array where each element is a vector of the series indices for a contiguous subseries
  [contiguous_subseries_indices, length_contiguous_subseries] = identify_contiguous_subseries(series_selection_idx);
  num_contiguous_subseries = length(contiguous_subseries_indices);

  if num_contiguous_subseries > 1
    % If we have more than one contiguous subseries then pick the longest one
    [max_len, max_idx] = max(length_contiguous_subseries);
    longest_contiguous_subseries = contiguous_subseries_indices{max_idx};
  else
    % Otherwise just 
    longest_contiguous_subseries = contiguous_subseries_indices{1};
  end
else
  longest_contiguous_subseries = [];
end


function [contiguous_subseries_indices, length_contiguous_subseries] = identify_contiguous_subseries(series_idx)

contiguous_subseries_indices = [];
length_contiguous_subseries = [];
j = 1; k = 1;

if isempty(series_idx)  
  return;
else
  series_run = series_idx(1);
  k = k + 1;

  for n=2:length(series_idx)
    series_idx_change = series_idx(n) - series_idx(n-1);

    if series_idx_change > 1
      contiguous_subseries_indices{j} = series_run;
      length_contiguous_subseries(j) = length(series_run);      

      j = j + 1; k = 1;
      series_run = [];
    end

    series_run(k,1) = series_idx(n);
    k = k + 1;
  end
end

contiguous_subseries_indices{j} = series_run;
length_contiguous_subseries(j) = length(series_run);