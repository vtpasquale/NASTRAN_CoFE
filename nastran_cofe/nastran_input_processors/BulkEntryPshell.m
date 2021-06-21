% Class for PSHELL property entries
% Anthony Ricciardi
%
classdef BulkEntryPshell < BulkEntry
    
    properties
        pid  % [uint32] Property identification number
        mid1 % [uint32] Membrane material identification number
        mid2 % [ int32] Bending material identification number
        mid3 % [uint32] Transverse shear material identification number
        mid4 % [uint32] Material identification number for membrane-bending coupling
        t    % [double] Default membrane thickness
        bendRatio  % [double] 12I/T^3 = ratio of the actual bending moment inertia of the shell, I, to the bending moment of inertia of a homogeneous shell, T^3/12. 
        shearRatio % [double] Ts/T = ratio of the shear thickness, Ts, to the membrane thickness of the shell, T. The typical value is for a homogeneous shell is 0.833333.
        nsm % [double] Nonstructural mass per unit area
        z1  % [double] Fiber distance for stress calculations
        z2  % [double] Fiber distance for stress calculations
    end
    properties (Hidden = true, Constant = true)
        DEFAULT_SHEAR_RATIO = 5/6;
    end
    
    methods
        function obj = BulkEntryPshell(entryFields)
            % Construct using entry field data input as cell array of char
            obj.pid  = castInputField('PSHELL','PID', entryFields{2},'uint32',NaN,1);
            obj.mid1 = castInputField('PSHELL','MID1',entryFields{3},'uint32',[],0);
            obj.t    = castInputField('PSHELL','T',   entryFields{4},'double',[],0);
            obj.mid2 = castInputField('PSHELL','MID2',entryFields{5},'int32',[],-1);
            obj.bendRatio = castInputField('PSHELL','12I/T**3',entryFields{6},'double',1.0,0);
            obj.mid3 = castInputField('PSHELL','MID3',entryFields{7},'uint32',[],1);
            obj.shearRatio = castInputField('PSHELL','TS/T',entryFields{8},'double',obj.DEFAULT_SHEAR_RATIO,0);
            obj.nsm = castInputField('PSHELL','NSM',entryFields{9},'double',0.0,0);
            if size(entryFields,2)>10
                obj.z1 = castInputField('PSHELL','Z1',entryFields{12},'double',[]);
                obj.z2 = castInputField('PSHELL','Z2',entryFields{13},'double',[]);
                obj.mid4 = castInputField('PSHELL','MID4',entryFields{14},'uint32',[],1);
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            pshell = Pshell;
            pshell.pid = obj.pid;
            pshell.t = obj.t;
            pshell.bendRatio = obj.bendRatio;
            pshell.shearRatio = obj.shearRatio;
            pshell.nsm = obj.nsm;
            
            pshell.mid1 = obj.mid1;
            pshell.mid2 = obj.mid2;
            pshell.mid3 = obj.mid3;
            pshell.mid4 = obj.mid4;
%             % checks 
%             if pshell.mid1 < 1; error('Only membrane response supported.'); end
%             if ~isempty(obj.mid2) | obj.mid2==-1; error('Only membrane response supported.'); end
%             if ~isempty(obj.mid3); error('Only membrane response supported.'); end
%             if ~isempty(obj.mid2); error('Only membrane response supported.'); end
            
            model.property = [model.property;pshell];
        end
        function echo_sub(obj,fid)
            % Print the entry in Nastran free field format to a text file with file id fid
            error('TODO')
        end
    end
end

