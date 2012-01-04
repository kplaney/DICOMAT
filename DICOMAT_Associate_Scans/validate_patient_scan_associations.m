
function valid_selections = validate_patient_scan_associations(GUI_data)

valid_selections = false;

if isfield(GUI_data, 'visible_panel') && ishandle(GUI_data.visible_panel.panel_handle) && isfield(GUI_data, 'behind_panel') && ishandle(GUI_data.behind_panel.panel_handle)
  if isfield(GUI_data.behind_panel, 'uicontrol_handles_array')
    [num_scans, num_fields] = size(GUI_data.behind_panel.uicontrol_handles_array);
    
    Patient_ID_idx = zeros(num_scans,1);
    Scan_Date_idx = zeros(num_scans,1);
    
    for n=1:num_scans
      Patient_ID_idx(n) = get(GUI_data.behind_panel.uicontrol_handles_array{n,2}, 'Value');
      Scan_Date_idx(n) = get(GUI_data.behind_panel.uicontrol_handles_array{n,3}, 'Value');  
    end
    
    user_selections_idx = find(Patient_ID_idx > 1);
    user_selections_values = [Patient_ID_idx(user_selections_idx) Scan_Date_idx(user_selections_idx)];
    
    num_selections = size(user_selections_values,1);
    num_unique_selections = size(unique(user_selections_values, 'rows'),1);
    
    if num_unique_selections == num_selections
      valid_selections = true;
    else
      uiwait(errordlg('Multiple scans associated with a given {patient id - scan date/type} pair', 'Validate Patient Scan Associations'));
    end
  end
end
