% Defines superelement type, and connections - remaining superelement data 
% are stored in seperate Model objects stored in same Model array
% Anthony Ricciardi
%
classdef SuperElement
   
    properties
        seida % [uint32 > 0] Partitioned superelement identification number.
        seidb % [unit32] Identification number of superelement for connection to SEIDA.
        type % [char] Superelement type: PRIMARY, EXTERNAL
        % method [char] must be MANUAL
        gida % [n,1 uint32] Identification numbers of a grid or scalar point in superelement seida, which will be connected to gidb.
        gidb % [n,1 uint32] Identification numbers of a grid or scalar point in superelement seidb, which will be connected to gida.
    end
    
    methods
        function index = getSuperElementIndex(obj,seid)
            seidas = [obj.seida];
            index = (seid == seidas);
            if sum(index) > 1
                error('SuperElement SEID %d defined more than once',seid)
            end
            if ~any(index)
                index = [];
            end
        end
        function obj = setSebulk(obj,seid,type)
            index = getSuperElementIndex(obj,seid);
            if isempty(index)
                superElement = SuperElement;
                superElement.seida = seid;
                superElement.type = type;
                obj = [obj;superElement];
            else
                % obj(index).seida = seid;
                obj(index).type = type;
            end
        end
        function obj = setSeconct(obj,seida,seidb,gida,gidb)
            index = getSuperElementIndex(obj,seida);
            if isempty(index)
                superElement = SuperElement;
                superElement.seida = seida;
                superElement.seidb = seidb;
                superElement.gida = gida;
                superElement.gidb = gidb;
                obj = [obj;superElement];
            else
                % obj(index).seida = seid;
                obj(index).seidb = seidb;
                obj(index).gida = gida;
                obj(index).gidb = gidb;
            end
            if seidb~=0
                error('SEIDB~=0 is not supported')
            end
        end
    end
    
end

