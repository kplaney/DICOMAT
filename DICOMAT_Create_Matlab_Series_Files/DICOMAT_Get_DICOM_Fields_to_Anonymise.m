
function DICOM_fields_to_anonymise = DICOMAT_Get_DICOM_Fields_to_Anonymise()

DICOM_fields_to_anonymise = [];

% DICOM Fields to Anonymise:
% See ftp://medical.nema.org/medical/dicom/final/sup55_ft.pdf and Table X.1-1 therein
% Columns represent: group tag, element tag, attribute name

DICOM_Anon_Attributes_Cell = {'0008','0014','Instance Creator UID';
                              '0008','0018','SOP Instance UID';
                              '0008','0050','Accession Number';
                              '0008','0080','Institution Name';
                              '0008','0081','Institution Address';
                              '0008','0090','Referring Physician’s Name';
                              '0008','0092','Referring Physician’s Address';
                              '0008','0094','Referring Physician’s Telephone Numbers';
                              '0008','1010','Station Name';
                              '0008','1030','Study Description';
                              '0008','103E','Series Description';
                              '0008','1040','Institutional Department Name';
                              '0008','1048','Physician(s) of Record';
                              '0008','1050','Performing Physicians’ Name';
                              '0008','1060','Name of Physician(s) Reading Study';
                              '0008','1070','Operators'' Name';
                              '0008','1080','Admitting Diagnoses Description';
                              '0008','1155','Referenced SOP Instance UID';
                              '0008','2111','Derivation Description';
                              '0010','0010','Patient''s Name';
                              '0010','0020','Patient ID';
                              '0010','0030','Patient''s Birth Date';
                              '0010','0032','Patient''s Birth Time';
                              '0010','0040','Patient''s Sex';
                              '0010','1000','Other Patient Ids';
                              '0010','1001','Other Patient Names';
                              '0010','1010','Patient''s Size';
                              '0010','1020','Patient''s Age';
                              '0010','1030','Patient''s Weight';
                              '0010','1090','Medical Record Locator';
                              '0010','2160','Ethnic Group';
                              '0010','2180','Occupation';
                              '0010','21B0','Additional Patient’s History';
                              '0010','4000','Patient Comments';
                              '0018','1000','Device Serial Number';
                              '0018','1030','Protocol Name';
                              '0020','000D','Study Instance UID';
                              '0020','000E','Series Instance UID';
                              '0020','0010','Study ID';
                              '0020','0052','Frame of Reference UID';
                              '0020','0200','Synchronization Frame of Reference UID';
                              '0020','4000','Image Comments';
                              '0040','0275','Request Attributes Sequence';
                              '0040','A124','UID';
                              '0040','A730','Content Sequence';
                              '0088','0140','Storage Media File-set UID';
                              '3006','0024','Referenced Frame of Reference UID';
                              '3006','00C2','Related Frame of Reference UID'};

% Loop over DICOM Attributes to Anonymise and see which are present in the DICOM data dictionary
for n=1:size(DICOM_Anon_Attributes_Cell,1)
	group = DICOM_Anon_Attributes_Cell{n,1};
	element = DICOM_Anon_Attributes_Cell{n,2};
	
	field_name = dicomlookup(group, element);
	
	if ~isempty(field_name)
		DICOM_fields_to_anonymise{length(DICOM_fields_to_anonymise)+1,1} = field_name;
	end
end
