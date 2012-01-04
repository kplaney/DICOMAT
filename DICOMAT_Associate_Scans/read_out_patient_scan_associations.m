
function Scan_Patient_Data_Struct = read_out_patient_scan_associations(GUI_data)

Scan_Patient_Data_Struct = [];

if isfield(GUI_data, 'behind_panel') && isfield(GUI_data.behind_panel, 'uicontrol_handles_array')
  % 
  uicontrol_handles_array = GUI_data.behind_panel.uicontrol_handles_array;  
  [num_scans, num_fields] = size(uicontrol_handles_array);
  
  for n=1:num_scans
    Scan_ID = get(uicontrol_handles_array{n,1}, 'String');
    
    Patient_ID_list = get(uicontrol_handles_array{n,2}, 'String');
    Patient_ID_idx = get(uicontrol_handles_array{n,2}, 'Value');
    Patient_ID = Patient_ID_list{Patient_ID_idx};
    
    if ~isempty(Patient_ID)
      Scan_Type_list = get(uicontrol_handles_array{n,3}, 'String');
      Scan_Type_idx = get(uicontrol_handles_array{n,3}, 'Value');
      Scan_Type = Scan_Type_list{Scan_Type_idx};

      Scan_Date_list = get(uicontrol_handles_array{n,4}, 'String');
      Scan_Date_idx = get(uicontrol_handles_array{n,4}, 'Value');
      Scan_Date = Scan_Date_list{Scan_Date_idx};

      idx = length(Scan_Patient_Data_Struct) + 1;
      
      Scan_Patient_Data_Struct(idx).Scan_ID = Scan_ID;      
      Scan_Patient_Data_Struct(idx).Patient_ID = Patient_ID;      
      Scan_Patient_Data_Struct(idx).Scan_Type = Scan_Type;
      Scan_Patient_Data_Struct(idx).Scan_Date = Scan_Date;
    end
  end
end
