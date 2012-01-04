
function Series_Options = DICOMAT_Series_Options_Mapping(handles, mode)

Series_Options = [];

menu_contents = cellstr(get(handles.series_type_popupmenu, 'String'));
selected_series_type = menu_contents{get(handles.series_type_popupmenu, 'Value')};

if strcmp(mode, 'setup')
	DICOMAT_Clear_Series_Options(handles);
				
	switch selected_series_type
		case ''
			return;
		case {'DCE-MRI', 'dPET/dCT'}
			DICOMAT_Setup_Dynamic_Acquisition_Options(handles.series_options_panel);
	end

	% Enable the Go button
	set(handles.go_pushbutton, 'Enable', 'on');
	
elseif strcmp(mode, 'readout')
	switch selected_series_type
		case ''
			uiwait(errordlg('Please select a valid series type', 'DICOMAT'));
			return;
		case {'DCE-MRI', 'dPET/dCT'}
			Series_Options.temporal_res = getappdata(handles.series_options_panel, 'temporal_res');
			Series_Options.num_pre_injection_vols = getappdata(handles.series_options_panel, 'num_pre_injection_vols');
	end

	% Get the pixel class
	contents = cellstr(get(handles.pixel_class_popupmenu,'String'));
	Series_Options.pixel_class = contents{get(handles.pixel_class_popupmenu,'Value')};
else
	uiwait(errordlg(sprintf('Unknown mode: %s', mode), mfilename));
end
