function obj = spcDof(obj)
s = []; % constrained degrees of freedom
iter = 0;

% Establish default single-point constraints
if isempty(obj.GRDSET) == 0
    if size(obj.GRDSET,1) > 1
        error('Only one GRDSET entry may appear in the Bulk Data Section')
    end
    if obj.GRDSET.PS == -999
        edof_default = '';
    else
        edof_default = num2str(obj.GRDSET.PS);
    end
else
    edof_default = '';
end

% Permanent single-point constraints
for i = 1:obj.nnodes
    if obj.GRID(i).PS == -999
        % use established default permanent single-point constraints 
        edof = edof_default;
    elseif obj.GRID(i).PS == 0
        % no permanent single-point constraints 
        edof = '';
    else
        % use grid-entry specified ps inputs
        edof = num2str(obj.GRID(i).PS);
    end
    for j = 1:length(edof)
        iter = iter + 1;
        s(iter,1) = obj.gnum2gdof(str2double(edof(j)),i);
    end
end

% multiple boundary condions not supported through subcases
if isempty([obj.CASE.SPC]); error('Boundary contions (CASE.SPC) undefined'); end
CASE_SPC = unique([obj.CASE.SPC]);
if size(CASE_SPC,2)~=1;
    error('Multiple boundary conditions (unique CASE.SPC numbers) not supported through subcases.  Run the separate boundary conditions with separate CoFE_analysis.m calls.')
end

% Single-point constraints specified using SPC1
if isempty(obj.SPC1) == 0
    nspc1 = size(obj.SPC1,2);
    for i = 1:nspc1
        if obj.SPC1(i).SID == CASE_SPC
            edof = num2str(obj.SPC1(i).C);
            for j = 1:length(edof)
                gdof = obj.gnum2gdof(str2double(edof(j)),find(obj.SPC1(i).G1==obj.gnum));
                if  any(gdof == s) == 0 % skip redundant dofs
                    iter = iter + 1;
                    s(iter,1) = gdof;
                end
            end
        else
%             warning(['Ignored boundary condition #',num2str(obj.SPC1(i).SID)])
        end
    end
end
obj.s = s;