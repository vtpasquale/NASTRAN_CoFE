% Class for FEMAP Neutral File Data Block 1051 - Output Data Vectors
% Anthony Ricciardi
%
classdef FemapDataBlock1051 < FemapDataBlock
    
    properties
        setID % [int] ID of output set
        vecID % [int] ID of output vector, must be unique in each output set
        
        title % [max 79 char] Output Vector title
        comp % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
        DoubleSidedContourVectorID % ?
        
        out_type % [int] Type of output (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
        ent_type % [int] Either nodal (7) or elemental (8) output
        compute_type % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
        
        calc_warn % [logical] If 1, can not linearly combine this output
        comp_dir % [int] If 1, comp[0..2] are the X,Y,Z component values. If 2, data at end of Beams. If 3, reverse data at second end of beam.
        cent_total % [logical] If 1, this vector has centroidal or nodal output.
        integer_format % [logical] If True, vector contains integer rather than floating point results
        
        entityID % [Nx1 int] Node/element IDs of the for results
        value % [Nx1 real] result values
    end
    properties (Constant= true, Hidden = true)
        DATA_BLOCK_ID = int32(1051);
        min_val = 999.  % [real] Minimum value in vector
        max_val = -999. % [real] Maximum value in vector. If max_val < min_val, FEMAP will search the output for the max, min and abs_max values.
        abs_max = 0.    % [real] Maximum absolute value in vector
        
        id_min = 0 % [int] ID of entity where minimum value occurs. (0 if FEMAP will recalc max/min)
        id_max = 0 % [int] ID of entity where maximum value occurs (0 if FEMAP will recalc max/min)
    end
    methods
        function writeNeutral_sub(obj,fid)
            % Writes single data block to FEMAP Neutral File
%             fprintf(fid,'   -1\n');
%             fprintf(fid,'  1051\n');
            fprintf(fid,'%d,%d,1\n',obj.setID,obj.vecID);
            fprintf(fid,'%s\n',obj.title);
            fprintf(fid,'%G,%G,%G\n',obj.min_val,obj.max_val,obj.abs_max);
            fprintf(fid,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',obj.comp( 1:10));
            fprintf(fid,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',obj.comp(11:20));
            fprintf(fid,'%d\n',obj.DoubleSidedContourVectorID);
            fprintf(fid,'%d,%d,%d,%d,%d\n',obj.id_min,obj.id_max,obj.out_type,obj.ent_type,obj.compute_type);
            fprintf(fid,'%d,%d,%d,%d\n',obj.calc_warn,obj.comp_dir,obj.cent_total,obj.integer_format);
            % checks
            [ne,me]=size(obj.entityID);
            [nv,mv]=size(obj.value);
            if me ~= 1; error('size(db1051.entityID) should be Nx1. size(db1051.entityID,2)~=1'); end
            if mv ~= 1; error('size(db1051.value) should be Nx1. size(db1051.value,2)~=1'); end
            if ne~=nv; error('db1051.entityID and db1051.value should be the same length'); end
            fprintf(fid,'%d,%f\n',[double(obj.entityID),obj.value]');
            fprintf(fid,'-1,0.\n');
        end
        function obj = FemapDataBlock1051(setID,vecID,title,comp,DoubleSidedContourVectorID,...
                out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                integer_format,entityID,value)
            % db1051 class constructor method
            if nargin~=0
                obj.setID=setID; % [int] ID of output set
                obj.vecID=vecID; % [int] ID of output vector, must be unique in each output set
                obj.title=title; % [max 79 char] Output Vector title
                obj.comp=comp; % [1x20 int] Component vectors. Either zero, or the IDs of the X,Y,Z components, or the IDs of the corresponding elemental corner output. See below.
                obj.DoubleSidedContourVectorID=DoubleSidedContourVectorID; % ?
                obj.out_type=out_type; % [int] Type of output (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
                obj.ent_type=ent_type; % [int] Either nodal (7) or elemental (8) output
                obj.compute_type=compute_type; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
                obj.calc_warn=calc_warn; % [logical] If 1, can not linearly combine this output
                obj.comp_dir=comp_dir; % [int] If 1, comp[0..2] are the X,Y,Z component values. If 2, data at end of Beams. If 3, reverse data at second end of beam.
                obj.cent_total=cent_total; % [logical] If 1, this vector has centroidal or nodal output.
                obj.integer_format=integer_format; % [logical] If True, vector contains integer rather than floating point results
                obj.entityID=entityID; % [Nx1 int] Node/element IDs of the for results
                obj.value=value; % [Nx1 real] result values
                %checks
                [ne,me]=size(obj.entityID);
                [nv,mv]=size(obj.value);
                if me ~= 1; error('size(db1051.entityID) should be Nx1. size(db1051.entityID,2)~=1'); end
                if mv ~= 1; error('size(db1051.value) should be Nx1. size(db1051.value,2)~=1'); end
                if ne~=nv; error('db1051.entityID and db1051.value should be the same length'); end
            end
        end
    end
    
end

