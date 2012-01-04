
function DICOMAT_Setup_Dynamic_Acquisition_Options(panel_handle)

x_text_offset = 0.0;
x_edit_offset = 0.4;
uiheight = 0.15;

normalised_fontsize = 0.45;

y_offset = 0.7;
uicontrol_pos = [x_text_offset y_offset 0.4 uiheight];
uicontrol('style', 'text', 'String', 'Number of pre-injection volumes:', ...
          'Fontunits', 'normalized', 'Fontsize', normalised_fontsize, ...
          'Parent', panel_handle, 'HorizontalAlignment', 'left', ...
          'Units', 'normalized', 'Position', uicontrol_pos);
          
uicontrol_pos = [x_edit_offset y_offset 0.2 uiheight];
uicontrol('style', 'edit', 'String', [], ...
          'Fontunits', 'normalized', 'Fontsize', normalised_fontsize, ...
          'Parent', panel_handle, 'Units', 'normalized', 'Position', uicontrol_pos, ...
          'Callback', {@num_pre_injection_vols_editbox_Callback, panel_handle});
          
y_offset = 0.5;
uicontrol_pos = [x_text_offset y_offset 0.4 uiheight];
uicontrol('style', 'text', 'String', 'Temporal resolution (secs):', ...
          'Fontunits', 'normalized', 'Fontsize', normalised_fontsize, ...
          'Parent', panel_handle, 'HorizontalAlignment', 'left', ...
          'Units', 'normalized', 'Position', uicontrol_pos);
          
uicontrol_pos = [x_edit_offset y_offset 0.2 uiheight];
uicontrol('style', 'edit', 'String', [], ...
          'Fontunits', 'normalized', 'Fontsize', normalised_fontsize, ...
          'Parent', panel_handle, 'Units', 'normalized', 'Position', uicontrol_pos, ...
          'Callback', {@temporal_res_editbox_Callback, panel_handle});


function num_pre_injection_vols_editbox_Callback(hObject, eventdata, panel_handle)
% hObject    handle to num_pre_injection_vols_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Hints: get(hObject,'String') returns contents of num_pre_injection_vols_editbox as text
%        str2double(get(hObject,'String')) returns contents of num_pre_injection_vols_editbox as a double

num_pre_injection_vols_str = get(hObject,'String');
num_pre_injection_vols = str2double(num_pre_injection_vols_str);
valid_integer = check_is_valid_integer(num_pre_injection_vols) && num_pre_injection_vols > 0;

if ~valid_integer
  uiwait(errordlg(sprintf('Invalid number of pre-injection volumes (%s)', num_pre_injection_vols_str), 'Number of pre-injection volumes'));
  set(hObject, 'String', []);
else
	setappdata(panel_handle, 'num_pre_injection_vols', num_pre_injection_vols);
end


function temporal_res_editbox_Callback(hObject, eventdata, panel_handle)
% hObject    handle to temporal_res_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Hints: get(hObject,'String') returns contents of temporal_res_editbox as text
%        str2double(get(hObject,'String')) returns contents of temporal_res_editbox as a double

temporal_res_str = get(hObject,'String');
temporal_res = str2double(temporal_res_str);
valid_double = check_is_valid_double(temporal_res) && temporal_res > 0;

if ~valid_double
  uiwait(errordlg(sprintf('Invalid temporal resolution (%s)', temporal_res_str), 'Temporal Resolution'));
  set(hObject, 'String', []);
else
	setappdata(panel_handle, 'temporal_res', temporal_res);
end
