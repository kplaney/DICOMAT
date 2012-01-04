
%
function scan_date_selection(h, ev, selected_scan_idx, uicontrol_handles_array)

menu_value = get(h, 'Value');
set(uicontrol_handles_array{selected_scan_idx,3}, 'Value', menu_value);
