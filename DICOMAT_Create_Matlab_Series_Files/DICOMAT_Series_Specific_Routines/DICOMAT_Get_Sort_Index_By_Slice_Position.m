
%% This function will create a sort index for sorting
%% DICOM files according to the slice position
%%
function [sort_idx, sorted_through_slice_projections, error_msg] = DICOMAT_Get_Sort_Index_By_Slice_Position(Info)

sort_idx = [];

% Check that the ImageOrientationPatient and ImagePositionPatient fields exist
if ~isfield(Info(1), 'ImageOrientationPatient')
  error_msg = sprintf('%s: DICOM field ImageOrientationPatient missing from Info');
  return;
end

if ~isfield(Info(1), 'ImagePositionPatient')
  error_msg = sprintf('%s: DICOM field ImagePositionPatient missing from Info');
  return;
end

% Create the through slice vector as the cross product of the slice in-plane axes
IOP = Info(1).ImageOrientationPatient;
through_slice_vector = cross(IOP(1:3), IOP(4:6));

% Create an N x 3 matrix of the ImagePositionPatient vectors
IPP_matrix = reshape([Info.ImagePositionPatient]', length(Info), 3);

% Project this matrix onto the through slice vector to get the slice location in this direction
through_slice_projections = IPP_matrix * through_slice_vector(:);

% Sort
[sorted_through_slice_projections, sort_idx] = sort(through_slice_projections);
