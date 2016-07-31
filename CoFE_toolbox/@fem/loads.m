function [lc,p] = loads(obj)

%% Checks
% Determine load case IDs referenced
% “simple loads” (e.g., FORCE, MOMENT) SIDs
slc = [];
for j = 1:size(obj.applied_loadList,2)
    if strcmp(obj.applied_loadList{j},'GRAV')==0
        slc = unique([slc,[obj.(obj.applied_loadList{j}).SID]]);
    end
end

% GRAV SIDs
glc = unique([obj.GRAV.SID]);

% LOAD SIDs
llc = unique([obj.LOAD.SID]);

% checks
if isempty(glc)==0
    if any(slc==glc)
        error('Acceleration or gravity loads may be combined with “simple loads” (e.g., FORCE, MOMENT) only by specification on a LOAD entry. That is, the SID on a GRAV entry may not be the same as that on a simple load entry.  This requirement is only enforced to maintain compatibility with MSC Nastran.  Inputs have violated this requirement.')
    end
end

if size(llc,2) < size(obj.LOAD,2)
    error('LOAD entry SID inputs should be unique.')
end

for i =1:size(obj.LOAD,2)
    if size(unique(obj.LOAD(i).Li),2) < size(obj.LOAD(i).Li,2)
        error('Load set IDs (Li) must be unique.')
    end
    if any(obj.LOAD(i).SID == obj.LOAD(i).Li)
        error('A LOAD entry may not reference itself.')
    end
end

%% Preallocate load vectors
lc = [slc,glc,llc];
p =zeros(obj.ndof,size(lc,2));

%% Loop through applied load entries
for j = 1:size(obj.applied_loadList,2)
    for i = 1:size(obj.(obj.applied_loadList{j}),2)
        
        % entry calculation
        [pl,gdof]=obj.(obj.applied_loadList{j})(i).apply(obj);
        lc_indx = find(obj.(obj.applied_loadList{j})(i).SID == lc);
        
        % apply load to load vector
        try
        p(gdof,lc_indx)=p(gdof,lc_indx)+pl;
        catch
            keyboard
        end
    end
end


%% LOAD entries
if ~isempty(llc)

    % generate LOAD cases accounting for dependency
    ssl = size([slc,glc],2); % number of nonLOAD cases
    unresolved = llc; % unresolved LOAD cases
    nllc = size(llc,2);
    iter = 0;
    while ~all(unresolved==0) % keep trying until dependency resolved
        iter = iter + 1;
        for i = 1:nllc % loop through load entries
            if unresolved(i) ~= 0
                if ~any(ismember(obj.LOAD(i).Li,unresolved)) % check that dependent load cases are resolved
                    
                    for ii = 1:size(obj.LOAD(i).Li,2)
                        if ismember(obj.LOAD(i).Li(ii),lc)==0
                            error(['LOAD entry with SID ',num2str(obj.LOAD(i).SID),' references undefined load case ',num2str(obj.LOAD(i).Li(ii)),'.'])
                        end
                        
                        p(:,ssl+i) = p(:,ssl+i) + obj.LOAD(i).Si(ii) * p(:,obj.LOAD(i).Li(ii)==lc);
                    end
                    unresolved(i) = 0; % resolved
                
                end
            end
        end
        
        if iter > nllc
            error('There are dependency issues with at least one of the LOAD input entries.')
        end
        
        if iter > 100*nllc
            error('CoFE appears to be stuck in the while loop that applies LOAD input entries.')
        end
    end
    
end
