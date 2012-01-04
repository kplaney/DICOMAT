
function initialise_scan_patient_data_scrolling_GUI(GUI_data, Patient_IDs, Scan_Types_Array, Scan_Dates_Array)

uicontrol_handles_array = GUI_data.behind_panel.uicontrol_handles_array;  
num_scans = size(uicontrol_handles_array,1);

unformatted_Scan_Dates_Array = cellfun(@(scan_date) unformat_date(scan_date), Scan_Dates_Array, 'UniformOutput', false);

Scan_ID_field = 1;
Patient_ID_field = 2;
Scan_Type_field = 3;
Scan_Date_field = 4;

for n=1:num_scans
  Scan_ID = get(uicontrol_handles_array{n,Scan_ID_field}, 'String');
  Parsed_Scan_ID = regexp(Scan_ID, filesep, 'split');

	This_Patient_ID = Parsed_Scan_ID{1};
	This_Scan_Info = Parsed_Scan_ID{2};

	Patient_ID_idx = strmatch(This_Patient_ID, Patient_IDs);

  if length(Patient_ID_idx) == 1
	  Patient_ID_menu_idx = Patient_ID_idx+1;
    set(uicontrol_handles_array{n,Patient_ID_field}, 'Value', Patient_ID_menu_idx);
		patient_id_selection(uicontrol_handles_array{n,Patient_ID_field}, [], n, uicontrol_handles_array, Scan_Types_Array, Scan_Dates_Array);

		Scan_idx = strmatch(This_Scan_Info, Scan_Types_Array(Patient_ID_idx,:));
	
		if isempty(Scan_idx)
			Scan_idx = strmatch(This_Scan_Info, unformatted_Scan_Dates_Array(Patient_ID_idx,:));
		end
		
		if length(Scan_idx) == 1
			Scan_menu_idx = Scan_idx+1;
			set(uicontrol_handles_array{n,Scan_Type_field}, 'Value', Scan_idx+1);
      set(uicontrol_handles_array{n,Scan_Date_field}, 'Value', Scan_idx+1);
		end
	end
end


function scan_date = unformat_date(scan_date)

if ~isempty(scan_date)
  scan_date = strrep(scan_date, '/', '');
else
	scan_date = '';
end
