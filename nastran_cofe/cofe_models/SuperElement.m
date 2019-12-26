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
        
%         bIndexInGa % [nBsetGdof,1 uint32] G-set index (in superelement seida) of B-set DOF defined by SECONCT
%         bIndexInGb % [nBsetGdof,1 uint32] G-set index (in superelement seidb) of B-set DOF defined by SECONCT
        modelIndex % [unit32] index of gida superelement model object in model array
        
%         aSetIndexInGSet  % [nAsetDof,1 uint32] GSET index (in this superelement) of boundary DOF defined by SECONCT
%         aSetIndexInGSet0 % [nAsetDof,1 uint32] GSET index (in residual structure) of boundary DOF defined by SECONCT
%         aSetIndexInASet0 % [nAsetDof,1 uint32] ASET index (in residual structure) of boundary DOF defined by SECONCT
        
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
        function model = preprocess(obj,model)
            % Function to preprocess superelement data
            
            [nModel,m]=size(model);
            if m~=1; error('Function only operates on Model arrays size n x 1.'); end
            
            % Process superelement data
            if nModel > 1
                nSuperElement = size(obj,1);
                if (nModel-1) ~= nSuperElement
                    error('SEBULK and SECONCT entries must be defined in the residual structure for all part superelements.')
                end
                superElementIDs = [model.superElementID];
                for i = 1:nSuperElement
                    if obj(i).seidb~=0; error('Only single level superlements supported. Check SEBULK and SECONCT entries.'); end
                    superElementIndex = find(obj(i).seida==superElementIDs);
                    if isempty(superElementIndex); error('SEIDA references undefined superelement #: %d',se(i).seida); end
                    if superElementIndex==1; error('SEIDA cannot reference the residual structure'); end
                    obj(i).modelIndex = superElementIndex;
                    modeli = model(superElementIndex);
                    points0 = model(1).point.getPoints(obj(i).gidb,model(1));
                    pointsi =   modeli.point.getPoints(obj(i).gida,modeli);

                    model(superElementIndex).seconctIndexInGSet0 = [points0.gdof]';
%                     model(superElementIndex).seconctIndexInGSet0 = false(model(1).nGdof,1); Don't use logical indexing because order matters
%                     model(superElementIndex).seconctIndexInGSet0([points0.gdof]) = true;
                    
                    model(superElementIndex).seconctIndexInGSet  = [pointsi.gdof]';
%                     model(superElementIndex).seconctIndexInGSet = false(model(superElementIndex).nGdof,1);
%                     model(superElementIndex).seconctIndexInGSet([pointsi.gdof]) = true;
                end
            end
            model(1).superElement = obj;
        end
    end
end

