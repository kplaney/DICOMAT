
function update_scan_patient_data_scrolling_GUI(GUI_data, Scan_Types_Array, Scan_Dates_Array)

Scan_Patient_Data_Struct = GUI_data.Scan_Patient_Data_Struct;
uicontrol_handles_array = GUI_data.behind_panel.uicontrol_handles_array;  
num_scans = size(uicontrol_handles_array,1);

for n=1:num_scans
  Scan_ID = get(uicontrol_handles_array{n,1}, 'String');
  
  % Find the matching record in the Scan Patient Data Struct for this Scan ID
  SPDS_idx = find_record_in_struct(Scan_Patient_Data_Struct, 'Scan_ID', Scan_ID);
  
  if ~isempty(SPDS_idx)
    % Now get the list of all the Patient IDs from the uicontrol handle
    Patient_IDs_list = get(uicontrol_handles_array{n,2}, 'String');
    
    % Find where in the list our selected Patient ID is
    Patient_ID = Scan_Patient_Data_Struct(SPDS_idx).Patient_ID;
    patient_menu_idx = strmatch(Patient_ID, Patient_IDs_list, 'exact');    
    
    if isempty(patient_menu_idx)
      msg = sprintf('Patient ID (%s) previously associated with Scan ID (%s) does not exist in the list of Patient IDs for this uicontrol.', Patient_ID, Scan_ID);
      uiwait(errordlg(msg, 'Update Scan Patient Data GUI', 'modal'));
      return;
    end
    
    if patient_menu_idx == 1
      % No Patient ID currently selected for this scan so deactivate scan types and date uicontrols
      set(uicontrol_handles_array{n,3}, 'Value', 1, 'String', {[]}, 'Enable', 'off');
      set(uicontrol_handles_array{n,4}, 'Value', 1, 'String', {[]}, 'Enable', 'off');
    else
      % Get a list of scan dates corresponding to this Patient ID
      Patient_ID_idx = patient_menu_idx - 1;
      valid_scan_dates_idx = cellfun(@(x) ~isempty(x), Scan_Dates_Array(Patient_ID_idx, :));
      Patient_Scan_Dates = Scan_Dates_Array(Patient_ID_idx, valid_scan_dates_idx);
      Patient_Scan_Types = Scan_Types_Array(Patient_ID_idx, valid_scan_dates_idx);

      % Find where in the list our selected Scan Date is
      Scan_Date = Scan_Patient_Data_Struct(SPDS_idx).Scan_Date;
      scan_menu_idx = strmatch(Scan_Date, Patient_Scan_Dates, 'exact');
      
      if ~isempty(scan_menu_idx)
        % If everything is ok and we have a valid Patient ID *and* Scan Date
        % then update the respective uicontrols to reflect the selections        
        set(uicontrol_handles_array{n,2}, 'Value', patient_menu_idx);        
        set(uicontrol_handles_array{n,3}, 'Value', scan_menu_idx, 'String', Patient_Scan_Types, 'Enable', 'on');
        set(uicontrol_handles_array{n,4}, 'Value', scan_menu_idx, 'String', Patient_Scan_Dates, 'Enable', 'on');
      end
    end
  end
end
