% Abstract superclass for single point constraints.
% Anthony Ricciardi
%
classdef (Abstract) Spcs < matlab.mixin.Heterogeneous
    
    properties (Abstract)
        sid % [int] Identification numbers of the single-point constraint sets.
    end
    methods (Sealed=true)
        function sb=preprocess(obj,model) % node2gdof,nodeIDs
            %
            % Outputs
            % sb ([ngdof,1] logical) Degrees-of-freedom eliminated by single-point constraints that are included in boundary conditions

            % Local variables before downselecting boundary condition:
            % sb ([ngdof,num SID] logical) Degrees-of-freedom eliminated by single-point constraints that are included in boundary conditions
            % spcsSIDs ([num SID,1] uint32) ID numbers of defined single point constraint sets
            
            % logic to deal with SPC and SPCADD types
            spcaddID = [];
            spcconID = [];
            for i = 1:size(obj,1)
                oi = obj(i);
                if isa(oi,'spcadd')
                    if any(spcaddID==oi.sid)
                        error('SID on SPCADD entries must be unique.')
                    end
                    spcaddID=[spcaddID;oi.sid];
                else
                    if ~any(spcconID==oi.sid)
                        spcconID=[spcconID;oi.sid];
                    end
                end
            end
            lia = ismember(spcaddID,spcconID);
            if any(lia)
                error('SPCADD SID(s): %s is(are) also used as SID(s) defined for SPC type entries. This is not allowed.',sprintf('%d,',spcconID(lia)))
            end
            spcsSIDs=[spcconID;spcaddID];
            
            % Preallocate sets
            sb=false(model.nGdof,max([size(spcsSIDs,1),1]));
            
            % Single point contraints
            objSid=[obj.sid];
            for i = 1:size(spcconID,1)
                oi=obj(objSid==spcconID(i));
                for j = 1:size(oi,1)
                    oj=oi(j);
                    for k = 1:size(oj.g,2)
                        point = model.point.getPoint(oj.g(k),model);
                        if isa(point,'Node')
                            gdof = point.gdof(oj.c);
                        elseif isa(point,'ScalarPoint')
                            if oj.c~=0
                                error('Only component zero can be fixed for a scalar point.')
                            end
                            gdof = point.gdof;
                        else
                            error('Update Spcs class for new point type.')
                        end
                        sb(gdof,i)=true;
                    end
                end
            end
            
            %%
            % Downselect boundary condition here (affects superelement set logic flow)
            % Nastran case control limitation requires this. Nastran allows 
            % sepearte BC for each load case for residual structure only -
            % not superelements.
            sidIndex = (model.caseControl(1).spc==spcsSIDs);
            if isempty(sidIndex) % isempty(obj.caseControl.spc) || isempty(obj.spcsSIDs)
                sb = false(model.nGdof,1);
            else
                sb=sb(:,sidIndex);
            end
            
            
        end % preprocess()
        
    end
end

