
function [Patient_Data_Struct, column_headings] = DICOMAT_Read_Patient_Data_File(patient_data_file)

disp(sprintf('Processing patient data file: %s', patient_data_file));

num_header_rows = 1;
disp('Assuming default of 1 header row');

[Patient_Data_Struct, column_headings] = read_structured_text_file(patient_data_file, num_header_rows);
