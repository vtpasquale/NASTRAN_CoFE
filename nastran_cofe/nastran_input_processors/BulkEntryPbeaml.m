% Class for PBEAML property entries
% Anthony Ricciardi
%
classdef BulkEntryPbeaml < BulkEntry
    
    properties
        pid % [uint32] Property identification number
        mid % [uint32] Material identification number
        group % [char] Cross-section group. (MSCBML0 or blank)
        type % [char] Cross-section shape. (BAR or ROD)
        dim % [n,1 double] Cross-section dimensions
        nsm % [double] Nonstructural mass per unit length
    end
    
    methods
        function obj = BulkEntryPbeaml(entryFields)
            % Construct using entry field data input as cell array of char
            obj.pid = castInputField('PBEAML','PID',entryFields{2},'uint32',NaN,1);
            obj.mid = castInputField('PBEAML','MID',entryFields{3},'uint32',NaN,1);
            obj.group = castInputField('PBEAML','GROUP',entryFields{4},'char','MSCBML0');
            obj.type = castInputField('PBEAML','TYPE',entryFields{5},'char',NaN);
            obj.type = upper(obj.type);
            if size(entryFields,2)<10
                error('PBEAML PID = %d entry continuation required.',obj.pid)
            end
            
            switch obj.type
                case 'BAR'
                    obj.dim(1) = castInputField('PBEAML','DIM1',entryFields{12},'double',[],0);
                    obj.dim(2) = castInputField('PBEAML','DIM2',entryFields{13},'double',[],0);
                    obj.nsm = castInputField('PBEAML','NSM',entryFields{14},'double',0.0,0);
                case 'ROD'
                    obj.dim(1) = castInputField('PBEAML','DIM1',entryFields{12},'double',[],0);
                    obj.nsm = castInputField('PBEAML','NSM',entryFields{13},'double',0.0,0);
                otherwise
                    error('PBEAML PID = %d, TYPE = %s not supported.',obj.pid,obj.type)
            end
            
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            
            % Convert BulkEntryPbeaml to BulkDataEntryPbeam
            bulkDataEntryPbeam = pbeaml2pbeam(obj);
            
            % Use BulkDataEntryPbeam method
            model = bulkDataEntryPbeam.entry2model_sub(model);
            
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'PBEAML,%d,%d,,%s\n',obj.pid,obj.mid,obj.type);
            switch obj.type
                case 'BAR'
                    fprintf(fid,',%f,%f,%f\n',obj.dim(1),obj.dim(2),obj.nsm);
                case 'ROD'
                    fprintf(fid,',%f,%f\n',obj.dim(1),obj.nsm);
                otherwise
                    error('PBEAML PID = %d, TYPE = %s not supported.',obj.pid,obj.type)
            end
        end
    end
    methods (Access = private)
        function bulkDataEntryPbeam = pbeaml2pbeam(obj)
            bulkPbeam.pid = obj.pid;
            bulkPbeam.mid = obj.mid;
            bulkPbeam.nsm = obj.nsm;
            switch obj.type
                case 'BAR'
                    b = obj.dim(1);
                    h = obj.dim(2);
                    bulkPbeam.a = b*h;
                    bulkPbeam.i1 = b.*h.^3./12;
                    bulkPbeam.i2 = b.^3.*h./12;
                    bulkPbeam.i12 = 0;
                    
                    % aa is the length of the long side
                    % bb is the length of the short side
                    if b >= h
                        aa = b; 
                        bb = h;
                    else
                        aa = h;
                        bb = b;
                    end
                    bulkPbeam.j = aa.*bb.^3.*(1./3-.21.*bb./aa.*(1-bb.^4./(12.*aa.^4)));
                    bulkPbeam.nsm = obj.nsm;
                    bulkPbeam.c1ThruF2 = [h./2,b./2,-h./2,b./2,-h./2,-b./2,h./2,-b./2];
                    bulkPbeam.k1 = 5/6;
                    bulkPbeam.k2 = 5/6;
                    bulkDataEntryPbeam = BulkEntryPbeam(bulkPbeam);

                case 'ROD'
                    bulkPbeam.a = pi.*obj.dim(1).^2;
                    bulkPbeam.i1 = pi./4.*obj.dim(1).^4;
                    bulkPbeam.i2 = pi./4.*obj.dim(1).^4;
                    bulkPbeam.i12 = 0;
                    bulkPbeam.j = pi./2.*obj.dim(1).^4;
                    bulkPbeam.c1ThruF2 = [obj.dim(1),0,0,obj.dim(1),-obj.dim(1),0,0,-obj.dim(1)];
                    bulkPbeam.k1 = 8.5716E-01; % Value Nastran uses (8.5716E-01) is inconsistent with Nastran documentation (0.9);
                    bulkPbeam.k2 = 8.5716E-01;
                    bulkDataEntryPbeam = BulkEntryPbeam(bulkPbeam);
                    
                otherwise
                    error('PBEAML PID = %d, TYPE = %s not supported.',obj.pid,obj.type)
            end
            if bulkPbeam.a <= 0; error('A < 0, there is an issues with PBEAML.'); end
        end
    end
end

