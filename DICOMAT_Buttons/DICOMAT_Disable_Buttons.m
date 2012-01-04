
function DICOMAT_Disable_Buttons(DICOMAT_GUI)

DICOMAT_guidata = guidata(DICOMAT_GUI);

set(DICOMAT_guidata.select_scans_button, 'Enable', 'off');
set(DICOMAT_guidata.load_study_data_button, 'Enable', 'off');
set(DICOMAT_guidata.associate_scans_button, 'Enable', 'off');
set(DICOMAT_guidata.create_matlab_series_files_button, 'Enable', 'off');
