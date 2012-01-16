
function Patient_Params = DICOMAT_Get_Patient_Params(Scan_ID, Patient_Data_Struct, Scan_Patient_Data_Struct, log_file, log_window_text)

Patient_Params = [];

MR_scan_param_tags = {'Weight', 'CA_Dose', 'CA_Type'};


if isempty(Patient_Data_Struct)
  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - no patient data loaded.', ...
                            Scan_ID), log_file, log_window_text);
  return;
end

if isempty(Scan_Patient_Data_Struct)
  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - no scans have been associated with patient data.', ...
                            Scan_ID), log_file, log_window_text);
  return;
end

SPDS_idx = find_record_in_struct(Scan_Patient_Data_Struct, 'Scan_ID', Scan_ID);

if isempty(SPDS_idx)
  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - scan has not been associated with patient data.', ...
                            Scan_ID), log_file, log_window_text);
  return;
end

Patient_ID = Scan_Patient_Data_Struct(SPDS_idx).Patient_ID;
Scan_Date = Scan_Patient_Data_Struct(SPDS_idx).Scan_Date;

if isempty(Patient_ID)
  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - scan is associated with an empty patient id.', ...
                            Scan_ID), log_file, log_window_text);
  return;
end

if isempty(Scan_Date)
  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - scan is associated with an empty scan date.', ...
                            Scan_ID), log_file, log_window_text);
  return;
end



% BAYER SCHERING HACK

%disp('** HACK for Bayer-Schering work: hard-coding patient ID field in Patient Data Struct to Mouse_ID - need to recode with association mapping **');
%
%PDS_idx = find_record_in_struct(Patient_Data_Struct, 'Mouse_ID', Patient_ID);
%
%if isempty(PDS_idx)
%  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - patient id (%s) does not exist in Patient Data Struct.', ...
%                            Scan_ID, Patient_ID), log_file, log_window_text);
%  return;
%end
%
%
%
%disp('** HACK for Bayer-Schering work: hard-coding patient param variables to add to DCE file **');
%
%switch Scan_Patient_Data_Struct(SPDS_idx).Scan_Type;
%	case {'Day -1', 'Day 0'}
%		Patient_Params.Weight = Patient_Data_Struct(PDS_idx).Day_1_MRI_weight_kg;
%		Patient_Params.CA_Dose = Patient_Data_Struct(PDS_idx).Day_1_MRI_CA_dose_mls;
%		Patient_Params.CA_Type = Patient_Data_Struct(PDS_idx).Day_1_MRI_CA_type;
%	case {'Day +3', 'Day +4'}
%		Patient_Params.Weight = Patient_Data_Struct(PDS_idx).Day_3_MRI_weight_kg;
%		Patient_Params.CA_Dose = Patient_Data_Struct(PDS_idx).Day_3_MRI_CA_dose_mls;
%		Patient_Params.CA_Type = Patient_Data_Struct(PDS_idx).Day_3_MRI_CA_type;
%	otherwise
%		disp('Problem - did not recognise Scan Type');
%		keyboard;
%end
%
%return;
%
%
%



PDS_idx = find_record_in_struct(Patient_Data_Struct, 'Patient_ID', Patient_ID);

if isempty(PDS_idx)
  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - patient id (%s) does not exist in Patient Data Struct.', ...
                            Scan_ID, Patient_ID), log_file, log_window_text);
  return;
end

Scan_Date_idx = find(structfun(@(fieldval) strcmp(fieldval, Scan_Date), Patient_Data_Struct(PDS_idx)));

if isempty(Scan_Date_idx)
  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - scan date (%s) does not exist for patient id (%s).', ...
                            Scan_ID, Scan_Date, Patient_ID), log_file, log_window_text);
  return;
end

PDS_fieldnames = fieldnames(Patient_Data_Struct);

Scan_Date_fieldname = lower(PDS_fieldnames{Scan_Date_idx});
Scan_Type = strrep(Scan_Date_fieldname, '_date', '');

scan_params_field_idx = find(cellfun(@(fieldname) ~isempty(strfind(fieldname, Scan_Type)), lower(PDS_fieldnames)));

if isempty(scan_params_field_idx)
  output_msg(sprintf('Scan ID: %s. Unable to add patient params to sequence file - cannot find any scan parameters corresponding to scan date (%s).', ...
                            Scan_ID, Scan_Date), log_file, log_window_text);
  return;
end


scan_params_fieldnames = PDS_fieldnames(scan_params_field_idx);

for p=1:length(MR_scan_param_tags)
  MR_scan_param_tag = MR_scan_param_tags{p};
  idx = find(cellfun(@(fieldname) ~isempty(strfind(fieldname, lower(MR_scan_param_tag))), lower(scan_params_fieldnames)));
  
  if isempty(idx)
    output_msg(sprintf('Scan ID: %s. Problem adding patient params to sequence file - cannot find MR patient parameter (%s) for MR scan type (%s).', ...
                              Scan_ID, MR_scan_param_tag, Scan_Type), log_file, log_window_text);
  else
    MR_scan_param_fieldname = scan_params_fieldnames{idx};
    Patient_Params.(MR_scan_param_tag) = Patient_Data_Struct(PDS_idx).(MR_scan_param_fieldname);
  end
end
