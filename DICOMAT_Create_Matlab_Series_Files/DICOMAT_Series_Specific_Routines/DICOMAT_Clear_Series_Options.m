
function DICOMAT_Clear_Series_Options(handles)

if isfield(handles, 'series_options_panel') && ishandle(handles.series_options_panel)
  delete(get(handles.series_options_panel, 'Children'));
else
  uiwait(errordlg('Could not find a handle for series_options_panel...', mfilename));
  return;
end
