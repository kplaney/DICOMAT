
function DICOMAT_Create_Patient_Data_Association_GUI(column_headings, parent_handle, Patient_Data_Associations)

% Setup fields
GUI_data.fields = {'Patient_ID', 'Scan_date', 'Scan_date', 'Scan_date', 'Scan_date', 'Scan_date', 'Scan_date'};
num_GUI_rows = length(GUI_data.fields);

% Set units for UI controls to normalized
set(0, 'defaultuicontrolunits', 'normalized');
fontsize = 0.4;
	
% Initialize and hide the GUI as it is being constructed.
fig_left = 0.2; fig_width = 0.5;
fig_bottom = 0.3; fig_height = 0.6;

fig_position = [fig_left fig_bottom fig_width fig_height];
fig = figure('Units', 'normalized', 'Visible', 'off', 'WindowStyle', 'modal', 'Position', fig_position);


% Reshape column headings cell into a column vector
column_headings = reshape(column_headings, length(column_headings), 1);

% Setup column headings cell array with a blank first entry
GUI_data.column_headings = {'', column_headings{:}}';

% Initialise menu selections from previous selections
menu_selections = ones(1, num_GUI_rows);
editbox_entries = cell(1, num_GUI_rows);
	
if ~isempty(Patient_Data_Associations)
	GUI_row = 1;
	menu_selections(GUI_row) = strmatch(Patient_Data_Associations.Patient_ID, GUI_data.column_headings, 'exact');
	
	for scan_idx=1:length(Patient_Data_Associations.Scan_dates)
		GUI_row = scan_idx + 1;
	  menu_selections(GUI_row) = strmatch(Patient_Data_Associations.Scan_dates{scan_idx}, GUI_data.column_headings, 'exact');
		editbox_entries{GUI_row} = Patient_Data_Associations.Folder_identifiers{scan_idx};
	end
end

% Set basic size properties for text, dropdown-menu, and edit ui's
text_left = 0.1; text_width = 0.1; text_height = 0.05;
menu_left = 0.3; menu_width = 0.25; menu_height = 0.05;
edit_left = 0.65; edit_width = 0.25; edit_height = 0.05;


% Loop over fields
for GUI_row=0:num_GUI_rows
  if GUI_row==0
    text_bottom = 0.9;
  else
    text_bottom = text_bottom - 0.1;
  end

  if GUI_row==0
	  text_pos = [text_left text_bottom text_width text_height];
	  menu_pos = [menu_left text_bottom menu_width text_height];
	  edit_pos = [edit_left text_bottom edit_width text_height];
	
    uicontrol('style', 'text', 'String', 'Field type:', 'Fontunits', 'normalized', ...
              'Fontsize', fontsize, 'Fontweight', 'bold', 'BackgroundColor', [0.8 0.8 0.8], ...
              'Position', text_pos, 'HorizontalAlignment', 'left');
    
    uicontrol('style', 'text', 'String', 'Column heading:', 'Fontunits', 'normalized', ...
              'Fontsize', fontsize, 'Fontweight', 'bold', 'BackgroundColor', [0.8 0.8 0.8], ...
              'Position', menu_pos, 'HorizontalAlignment', 'left');

		uicontrol('style', 'text', 'String', 'Folder identifier:', 'Fontunits', 'normalized', ...
		          'Fontsize', fontsize, 'Fontweight', 'bold', 'BackgroundColor', [0.8 0.8 0.8], ...
		          'Position', edit_pos, 'HorizontalAlignment', 'left');					
  else
	  text_pos = [text_left text_bottom text_width text_height];
	  menu_pos = [menu_left text_bottom menu_width menu_height];
	  edit_pos = [edit_left text_bottom edit_width edit_height];
	
    GUI_data.text_ui(GUI_row) = uicontrol('style', 'text', 'String', GUI_data.fields{GUI_row}, 'Fontunits', 'normalized', ...
                                           'Fontsize', fontsize, 'BackgroundColor', [0.8 0.8 0.8], ...
                                           'Position', text_pos, 'HorizontalAlignment', 'left');
    
    GUI_data.menu_ui(GUI_row) = uicontrol('style', 'popupmenu', 'String', GUI_data.column_headings, 'Fontunits', 'normalized', ...
                                           'Fontsize', fontsize, 'BackgroundColor', [0.8 0.8 0.8], ...
                                           'Position', menu_pos, 'HorizontalAlignment', 'left', ...
                                           'Value', menu_selections(GUI_row));
		
		if GUI_row > 1
			GUI_data.edit_ui(GUI_row) = uicontrol('style', 'edit', 'String', editbox_entries{GUI_row ...
			}, 'Fontunits', 'normalized', ...
		                                        'Fontsize', fontsize, 'BackgroundColor', [1 1 1], ...
		                                        'Position', edit_pos, 'HorizontalAlignment', 'left');
		else
			GUI_data.edit_ui(GUI_row) = 0;
		end
	end
end

% Setup ok and cancel buttons
uicontrol('style', 'pushbutton', 'String', 'OK', 'Fontunits', 'normalized', ...
          'Fontsize', 0.5, 'Position', [0.25 0.04 0.15 0.05], 'enable', 'on', ...
          'callback', {@DICOMAT_Process_Patient_Data_Association, parent_handle, 'ok'});

uicontrol('style', 'pushbutton', 'String', 'Cancel', 'Fontunits', 'normalized', ...
          'Fontsize', 0.5, 'Position', [0.6 0.04 0.15 0.05], 'enable', 'on', ...
          'callback', {@DICOMAT_Process_Patient_Data_Association, parent_handle, 'cancel'});

% Save GUI data into figure handle
guidata(fig, GUI_data);

% Center GUI
movegui(fig,'center');

% Make the GUI visible.
set(fig, 'Visible','on', 'Name', 'Select patient data fields', ...
         'Numbertitle', 'off', 'toolbar', 'none', 'MenuBar', 'none');
