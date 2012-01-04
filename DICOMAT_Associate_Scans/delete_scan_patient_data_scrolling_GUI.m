
function GUI_data = delete_scan_patient_data_scrolling_GUI(GUI_data)

% Delete visible panel controls
if isfield(GUI_data, 'visible_panel')
  if isfield(GUI_data.visible_panel, 'header_text_handles')
    
    % Delete all text handles in visible panel
    for i=1:size(GUI_data.visible_panel.header_text_handles,1)
      for j=1:size(GUI_data.visible_panel.header_text_handles,2)
        if ishandle(GUI_data.visible_panel.header_text_handles{i,j})
          delete(GUI_data.visible_panel.header_text_handles{i,j});
        end
      end
    end
    
    GUI_data.visible_panel = rmfield(GUI_data.visible_panel, 'header_text_handles');    
  end
  
	% Delete the slider from the visible panel
	if isfield(GUI_data.visible_panel, 'slider_handle') && ishandle(GUI_data.visible_panel.slider_handle)
		delete(GUI_data.visible_panel.slider_handle);
		GUI_data.visible_panel = rmfield(GUI_data.visible_panel, 'slider_handle');
	end
	
  % Remove the field from the GUI data struct
  GUI_data = rmfield(GUI_data, 'visible_panel');
end

% Delete behind panel controls
if isfield(GUI_data, 'behind_panel')
  if isfield(GUI_data.behind_panel, 'uicontrol_handles_array')
    
    for i=1:size(GUI_data.behind_panel.uicontrol_handles_array,1)
      for j=1:size(GUI_data.behind_panel.uicontrol_handles_array,2)
        if ishandle(GUI_data.behind_panel.uicontrol_handles_array{i,j})
          delete(GUI_data.behind_panel.uicontrol_handles_array{i,j});
        end
      end
    end

    GUI_data.behind_panel = rmfield(GUI_data.behind_panel, 'uicontrol_handles_array');
  end
  
  % Delete the actual behind panel
  if ishandle(GUI_data.behind_panel.panel_handle)
    delete(GUI_data.behind_panel.panel_handle);
  end

  % Remove the field from the GUI data struct
  GUI_data = rmfield(GUI_data, 'behind_panel');
end

