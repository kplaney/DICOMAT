
function DICOMAT_Reset_DICOM_Metadata_GUI(parent_GUI_handle, new_GUI_position)

GUI_color = get(0, 'defaultUicontrolBackgroundColor');

% Create GUI figure
fig = figure('Toolbar', 'none', 'Units', 'normalized', ...
						 'position', new_GUI_position, 'Color', GUI_color, ...
						 'Name', '', 'MenuBar', 'none', 'NumberTitle', 'off');
						
set(fig, 'CloseRequestFcn', {@reactivate_parent_GUI, parent_GUI_handle, fig});

% Create outer panel handle - decorative
outer_panel_gap = 0.02; outer_panel_y_offset = 0.1; 
outer_panel_pos = [outer_panel_gap outer_panel_y_offset (1-2*outer_panel_gap) (1-outer_panel_y_offset-outer_panel_gap)];

outer_panel_handle = uipanel('Parent', fig, 'Title', 'Reset DICOM Metadata', ...
											 			 'BackgroundColor', GUI_color, ...
											 			 'Units', 'normalized', 'Position', outer_panel_pos);

% Create inner panel handle - which will be the parent for the listbox
inner_panel_gap = 0.02; inner_panel_y_offset = inner_panel_gap;
inner_panel_pos = [inner_panel_gap inner_panel_y_offset (1-2*inner_panel_gap) (1-inner_panel_y_offset-inner_panel_gap)];

inner_panel_handle = uipanel('Parent', outer_panel_handle, ...
											 			 'BackgroundColor', GUI_color, ...
											 			 'BorderType', 'none', ...
											 			 'Units', 'normalized', 'Position', inner_panel_pos);

total_num_rows = 12;

% Entry types
type_strings = {'text', 'numeric'};

% Create uicontrols
ui_x_offset1 = 0.025; ui_x_offset2 = 0.375; ui_x_offset3 = 0.825;
ui_initial_y_offset = 0.9;

ui_width = 0.3; ui_width2 = 0.4; ui_width3 = 0.15;
ui_height = ui_initial_y_offset/(total_num_rows);
ui_fontsize = 0.4;

for d=0:total_num_rows
	ui_y_offset = ui_initial_y_offset - d*ui_height;
	
	if d == 0
		% Header rows at the top
		uicontrol_pos = [ui_x_offset1 ui_y_offset ui_width ui_height];
		uicontrol('style', 'text', 'String', 'DICOM Field', 'Fontunits', 'normalized', ...
            	'Fontsize', ui_fontsize, 'FontWeight', 'bold', 'Parent', inner_panel_handle, ...
            	'Units', 'normalized', 'HorizontalAlignment', 'center', 'Position', uicontrol_pos);

		uicontrol_pos = [ui_x_offset2 ui_y_offset ui_width2 ui_height];
		uicontrol('style', 'text', 'String', 'New Value', 'Fontunits', 'normalized', ...
            	'Fontsize', ui_fontsize, 'FontWeight', 'bold', 'Parent', inner_panel_handle, ...
            	'Units', 'normalized', 'HorizontalAlignment', 'center', 'Position', uicontrol_pos);		

		uicontrol_pos = [ui_x_offset3 ui_y_offset ui_width3 ui_height];
		uicontrol('style', 'text', 'String', 'Type', 'Fontunits', 'normalized', ...
            	'Fontsize', ui_fontsize, 'FontWeight', 'bold', 'Parent', inner_panel_handle, ...
            	'Units', 'normalized', 'HorizontalAlignment', 'center', 'Position', uicontrol_pos);		
	else
		% Edit field for DICOM field name (shift up a bit to align with the type popupmenu)
		uicontrol_pos = [ui_x_offset1 ui_y_offset+0.01 ui_width ui_height];
		h(d,1) = uicontrol('style', 'edit', 'String', [], 'Fontunits', 'normalized', ...
          					 	 'Fontsize', ui_fontsize, 'FontWeight', 'normal', 'Parent', inner_panel_handle, ...
          					   'Units', 'normalized', 'HorizontalAlignment', 'left', 'Position', uicontrol_pos);
    
		% Edit field for new value (shift up a bit to align with the type popupmenu)
		uicontrol_pos = [ui_x_offset2 ui_y_offset+0.01 ui_width2 ui_height];
		h(d,2) = uicontrol('style', 'edit', 'String', [], 'Fontunits', 'normalized', ...
            					 'Fontsize', ui_fontsize, 'FontWeight', 'normal', 'Parent', inner_panel_handle, ...
            					 'Units', 'normalized', 'HorizontalAlignment', 'center', 'Position', uicontrol_pos);

		% Popupmenu for new value type
		uicontrol_pos = [ui_x_offset3 ui_y_offset ui_width3 ui_height];
		h(d,3) = uicontrol('style', 'popupmenu', 'String', {[], type_strings{:}}, 'Fontunits', 'normalized', ...
            					 'Fontsize', ui_fontsize, 'FontWeight', 'normal', 'Parent', inner_panel_handle, ...
            					 'Units', 'normalized', 'HorizontalAlignment', 'center', 'Position', uicontrol_pos);
	end
end

% Setup ok and cancel buttons
uicontrol('style', 'pushbutton', 'String', 'OK', ...
				  'Fontunits', 'normalized', 'Fontsize', 0.3, ...
					'Units', 'normalized', 'Position', [0.3 0.03 0.1 0.05], ...
					'Parent', fig, 'callback', {@DICOMAT_Validate_DICOM_Field_Entries, parent_GUI_handle, fig, h});

uicontrol('style', 'pushbutton', 'String', 'Cancel', ...
					'Fontunits', 'normalized', 'Fontsize', 0.3, ...
					'Units', 'normalized', 'Position', [0.6 0.03 0.1 0.05], ...
          'Parent', fig, 'callback', {@reactivate_parent_GUI, parent_GUI_handle, fig});

% Make parent GUI invisible
set(parent_GUI_handle, 'Visible', 'off');

% Clear any pre-existing selections from memory by removing
% the DICOM_field_updates variable from the parent GUI data
GUI_data = guidata(parent_GUI_handle);

if isfield(GUI_data, 'DICOM_field_updates')
	rmfield(GUI_data, 'DICOM_field_updates');
end

guidata(parent_GUI_handle, GUI_data);
