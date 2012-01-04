
function [visible_panel, behind_panel] = create_scan_patient_data_scrolling_GUI(visible_panel_handle, Scan_Dirnames, Patient_IDs, Scan_Types_Array, Scan_Dates_Array, varargin)

% 
if length(varargin)
  Scan_Patient_Data_Struct = varargin{1};
else
  Scan_Patient_Data_Struct = [];
end

% 
visible_panel.header_text_handles = [];
behind_panel.uicontrol_handles_array = [];

% 
visible_panel.panel_handle = visible_panel_handle;

% 
behind_panel.uicontrol_height = 0.05;
behind_panel.uicontrol_vert_sep = 0.03;
behind_panel.uicontrol_width = [0.4 0.15 0.15 0.15];
behind_panel.uicontrol_horiz_sep = 0.23;
behind_panel.uicontrol_x_offset = 0.05;

normalised_fontsize = 0.35;  
num_scans = length(Scan_Dirnames);

% 
if num_scans
  behind_panel.panel_handle = uipanel('BorderType', 'none', 'Units', 'normalized', 'Position', [0 0 1 1], 'Parent', visible_panel.panel_handle);
  behind_panel.num_scans_out_of_panel_range = 0;  
  
  % Loop over Scan IDs
  for s=0:num_scans
    x_offset = behind_panel.uicontrol_x_offset;
    y_offset = 0.9 - (s * (behind_panel.uicontrol_vert_sep + behind_panel.uicontrol_height));
    
    if s == 1
      behind_panel.uicontrol_max_y_offset_visible_range = y_offset;
    end
    
    for u=1:4
      uicontrol_pos = [x_offset y_offset behind_panel.uicontrol_width(u) behind_panel.uicontrol_height];
      
      if s == 0
        switch u
         case 1          
          text_str = 'Scan ID:';
         case 2          
          text_str = 'Patient ID:';
         case 3          
          text_str = 'Scan Type:';
         case 4          
          text_str = 'Scan Date:';
        end
        
        visible_panel.header_text_handles{u} = uicontrol('style', 'text', 'String', text_str, 'Fontunits', 'normalized', ...
                                                         'Fontsize', normalised_fontsize, 'FontWeight', 'bold', ...
                                                         'Fontname', 'FixedWidth', 'Parent', visible_panel.panel_handle, ...
                                                         'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', uicontrol_pos);
      else
        switch u
         case 1
          ui_style = 'text';
          text_str = Scan_Dirnames{s};
         case 2
          ui_style = 'popupmenu';
          text_str = {[], Patient_IDs{:}};
         case 3
          ui_style = 'popupmenu';
          text_str = {[]}; 
         case 4
          ui_style = 'popupmenu';
          text_str = {[]}; 
        end
        
        behind_panel.uicontrol_handles_array{s,u} = uicontrol('style', ui_style, 'String', text_str, 'Fontunits', 'normalized', ...
                                                          		'Fontsize', normalised_fontsize, 'FontWeight', 'normal', 'Fontname', 'FixedWidth', ...
                                                          		'Parent', behind_panel.panel_handle, 'Units', 'normalized', ...
                                                          		'HorizontalAlignment', 'left', 'Position', uicontrol_pos, ...
                                                          		'Visible', 'off', 'Enable', 'off');
      end
      
      x_offset = x_offset + behind_panel.uicontrol_horiz_sep;
    end    
  end
  
  for s=1:num_scans
    set(behind_panel.uicontrol_handles_array{s,2}, 'Callback', {@patient_id_selection, s, behind_panel.uicontrol_handles_array, Scan_Types_Array, Scan_Dates_Array});
    set(behind_panel.uicontrol_handles_array{s,3}, 'Callback', {@scan_type_selection, s, behind_panel.uicontrol_handles_array});
    set(behind_panel.uicontrol_handles_array{s,4}, 'Callback', {@scan_date_selection, s, behind_panel.uicontrol_handles_array});
  end
  
  num_scans_out_of_panel_range = update_uicontrol_visibility_and_enable_status(behind_panel, 0);
  
  if num_scans_out_of_panel_range > 0
    visible_panel = setup_GUI_panel_slider(num_scans_out_of_panel_range, visible_panel, behind_panel);
  end
  
  uicontrol_handles_array = behind_panel.uicontrol_handles_array;
  header_text_handles = visible_panel.header_text_handles;
else
  uiwwait(errordlg('No scans selected', 'Associate Scans with Patients'));
end


function num_scans_out_of_panel_range = update_uicontrol_visibility_and_enable_status(behind_panel, panel_y_shift)

num_scans = size(behind_panel.uicontrol_handles_array,1);
num_uicontrols_per_scan = size(behind_panel.uicontrol_handles_array,2);

num_scans_out_of_panel_range = 0;

for s=1:num_scans
  relative_pos = get(behind_panel.uicontrol_handles_array{s,1}, 'Position');
end

for s=1:num_scans
  position_within_panel = get(behind_panel.uicontrol_handles_array{s,1}, 'Position');
  uicontrol_y_offset = position_within_panel(2) + panel_y_shift;
  
  if uicontrol_y_offset >= 0 && uicontrol_y_offset <= behind_panel.uicontrol_max_y_offset_visible_range
    set(behind_panel.uicontrol_handles_array{s,1}, 'Visible', 'on', 'Enable', 'on');
    set(behind_panel.uicontrol_handles_array{s,2}, 'Visible', 'on', 'Enable', 'on');
    set(behind_panel.uicontrol_handles_array{s,3}, 'Visible', 'on');
    set(behind_panel.uicontrol_handles_array{s,4}, 'Visible', 'on');

    if get(behind_panel.uicontrol_handles_array{s,2}, 'Value') > 1
      set(behind_panel.uicontrol_handles_array{s,3}, 'Enable', 'on');
			set(behind_panel.uicontrol_handles_array{s,4}, 'Enable', 'on');
    end
  else
    set(behind_panel.uicontrol_handles_array{s,1}, 'Visible', 'off', 'Enable', 'off');
    set(behind_panel.uicontrol_handles_array{s,2}, 'Visible', 'off', 'Enable', 'off');
    set(behind_panel.uicontrol_handles_array{s,3}, 'Visible', 'off', 'Enable', 'off');
    set(behind_panel.uicontrol_handles_array{s,4}, 'Visible', 'off', 'Enable', 'off');

    num_scans_out_of_panel_range = num_scans_out_of_panel_range + 1;
  end
end


function visible_panel = setup_GUI_panel_slider(num_scans_out_of_panel_range, visible_panel, behind_panel)

slider_width = 0.05;
slider_pos = [(1-slider_width) 0 slider_width 1];

max_slider_value = num_scans_out_of_panel_range+1;
slider_step = [1/max_slider_value min([1 5/max_slider_value])];

visible_panel.slider_handle = uicontrol('style', 'slider', 'min', 1, 'max', max_slider_value, ...
                          							'value', max_slider_value, 'SliderStep', slider_step, ...
                          							'Units', 'normalized', 'Position', slider_pos, ...
                          							'Parent', visible_panel.panel_handle, 'callback', []);

set(visible_panel.slider_handle, 'callback', {@scroll_panel_update, behind_panel});


%
function scroll_panel_update(slider_handle, events, behind_panel)

slider_max_value = get(slider_handle, 'max');
slider_increment = slider_max_value - floor(get(slider_handle, 'value'));

panel_y_shift = slider_increment * (behind_panel.uicontrol_height + behind_panel.uicontrol_vert_sep);
set(behind_panel.panel_handle, 'Position', [0 panel_y_shift 1 1]);

update_uicontrol_visibility_and_enable_status(behind_panel, panel_y_shift);


