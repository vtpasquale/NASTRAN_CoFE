% Abstract superclass for single point constraints.
% Anthony Ricciardi
%
classdef (Abstract) Spcs < matlab.mixin.Heterogeneous

    properties (Abstract)
        sid % [int] Identification numbers of the single-point constraint sets.
    end
    methods (Sealed=true)
        function [sb,sd,spcsSIDs]=process_sb(obj,model) % node2gdof,nodeIDs
            %
            % Outputs
            % sb ([ngdof,num SID] logical) Degrees-of-freedom eliminated by single-point constraints that are included in boundary conditions
            % sd ([ngdof,num SID] sparse) Enforced displacement values due to single-point constraints that are included in boundary conditions
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
            sd=spalloc(size(sb,1),size(sb,2),ceil(size(sb,1)/10)*size(sb,2));
            
            % Single point contraints
            objSid=[obj.sid];
            for i = 1:size(spcconID,1)
                oi=obj(objSid==spcconID(i));
                for j = 1:size(oi,1)
                    oj=oi(j);
                    node = model.point.getNode(oj.g,model);
                    gdof = node.gdof(oj.c);
                    sd(gdof,i)=oj.d;
                    sb(gdof,i)=true;
                end
            end
        end % process_sb()
        
%             ii = i;
%             %% SPCADD
%             for i = 1:size(spcaddID,1)
%                 oi=obj([obj.SID]==spcaddID(i));
%                 for j = 1:size(oi,1)
%                     oj=oi(j);
%                     
%                 end
%             end

    end % methods
end

