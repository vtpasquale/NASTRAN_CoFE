% Class for output data at elements
% Anthony Ricciardi
%
classdef element_output_data
    
    properties
        ID % [uint32] Output element identification number
        elem_type % [uint8] NASTRAN element code corresponding to NASTRAN item codes documentation
        response_type % [uint8] CoFE code specifying response type [1=FORCE,2=STRESS,3=STRAIN,4=STRAIN ENERGY,5=KINETIC ENERGY]
        values % [n_items,n_response_vectors] Element output data
        %         stress % [n_element_stress_item_codes,n_response_vectors] Stress values according to NASTRAN item codes documentation
        %         strain % [n_element_strain_item_codes,n_response_vectors] Strain values according to NASTRAN item codes documentation
        %         force % [n_element_force_item_codes,n_response_vectors] Element force values according to NASTRAN item codes documentation
        %         ese % [nm,1] Element strain energy for all response modes
        %         eke % [nm,1] Element kinetic energy for all response modes
    end
    
    methods
        function obj = element_output_data(ID,elem_type,response_type,values)
            obj.ID = ID;
            obj.elem_type = elem_type;
            obj.response_type = response_type;
            obj.values = values;
        end
        function obj = set.elem_type(obj,in)
            if isnumeric(in)==0; error('element_output_data.elem_type must be a number'); end
            if mod(in,1) ~= 0; error('element_output_data.elem_type must be an integer'); end
            if in < 1 || in > 255; error('element_output_data.response_type must be greater than zero and less than 255.'); end
            obj.elem_type=uint8(in);
        end
        function obj = set.response_type(obj,in)
            if isnumeric(in)==0; error('element_output_data.response_type must be a number'); end
            if mod(in,1) ~= 0; error('element_output_data.response_type must be an integer'); end
            if in < 1 || in > 4; error('element_output_data.response_type must be greater than zero and less than 5.'); end
            obj.response_type=uint8(in);
        end
        function DB = convert_2_db1051(obj,MODEL,StartSetID)
            DB = [];
            elem_types = [obj.elem_type];
            unique_elem_types = unique(elem_types);
            for i = 1:size(unique_elem_types,2)
                index = elem_types==unique_elem_types(i);
                obj_i = obj(index);
                EIDs = [obj_i.ID].';
                model_index = ismember(EIDs,MODEL.elemEIDs);
                rtype=unique([obj_i.response_type]);
                if size(rtype,2)~=1; error('There is more than one response type in the call to convert_2_db1051. Data processing should have prevented this.'); end
                switch rtype
                    case 1
                        DB = [DB;MODEL.ELEM(model_index).force_2_db1051(obj_i,StartSetID)];
                    case 2
                        DB = [DB;MODEL.ELEM(model_index).stress_2_db1051(obj_i,StartSetID)];
                end
            end
        end
    end
end
