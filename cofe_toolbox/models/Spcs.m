% Abstract superclass for single point constraints.
% Anthony Ricciardi
%
classdef (Abstract) Spcs < matlab.mixin.Heterogeneous

    properties (Abstract)
        sid % [int] Identification numbers of the single-point constraint sets.
    end
    methods (Sealed=true)
        function [sb,sd,spcsSIDs]=process_sb(obj,node2gdof)
            
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
            sb=false(size(node2gdof,2)*6,max([size(spcsSIDs,1),1]));
            sd=spalloc(size(sb,1),size(sb,2),ceil(size(sb,1)/10)*size(sb,2));
            
            %% Single point contraints
            for i = 1:size(spcconID,1)
                oi=obj([obj.sid]==spcconID(i));
                for j = 1:size(oi,1)
                    oj=oi(j);
                    gdof = node2gdof(oj.C,oj.G);
                    gdof = gdof(:);
                    sd(gdof,i)=oj.D;
                    sb(gdof,i)=true;
                end
            end
            
%             ii = i;
%             %% SPCADD
%             for i = 1:size(spcaddID,1)
%                 oi=obj([obj.SID]==spcaddID(i));
%                 for j = 1:size(oi,1)
%                     oj=oi(j);
%                     
%                 end
%             end
            
            
        end
    end
    
end

