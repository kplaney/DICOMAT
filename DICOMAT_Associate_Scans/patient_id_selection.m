%
function patient_id_selection(h, ev, selected_scan_idx, uicontrol_handles_array, Scan_Types_Array, Scan_Dates_Array)

menu_value = get(h, 'Value');

if menu_value == 1
  set(uicontrol_handles_array{selected_scan_idx,3}, 'Value', 1, 'String', {[]}, 'Enable', 'off');
  set(uicontrol_handles_array{selected_scan_idx,4}, 'Value', 1, 'String', {[]}, 'Enable', 'off');
else
  valid_idx = find(cellfun(@(x) ~isempty(x), Scan_Dates_Array(menu_value-1, :)));

  Valid_Scan_Types = {[], Scan_Types_Array{menu_value-1, valid_idx}};
  Valid_Scan_Dates = {[], Scan_Dates_Array{menu_value-1, valid_idx}};

  set(uicontrol_handles_array{selected_scan_idx,3}, 'Value', 1, 'String', Valid_Scan_Types, 'Enable', 'on');
  set(uicontrol_handles_array{selected_scan_idx,4}, 'Value', 1, 'String', Valid_Scan_Dates, 'Enable', 'on');
end
