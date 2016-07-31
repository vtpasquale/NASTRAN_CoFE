function [obj,obj_prime]= analysis_105(obj,obj_ref,obj_prime,obj_ref_prime)

if nargout > 1
    ndv = size(obj_prime,1);
end

%% Determine number of roots desired from EIGRL input cooresponding to
% the METHOD specified in the case
assert(isempty(obj.CASE.METHOD) == 0,'fem.CASE.METHOD must be specified for SOL = 105 cases.');
assert(isempty(obj.EIGRL) == 0,'An EIGRL entry must be specified for SOL = 105 cases.');
obj.ND = obj.EIGRL(obj.CASE.METHOD == [obj.EIGRL.SID]).ND;


%% Differential stiffness matrix
obj.KD_G = spalloc(obj.ndof,obj.ndof,20*obj.ndof);

% Loop through element types
for j = 1:size(obj.elementList,2)
    for i = 1:size(obj.(obj.elementList{j}),2)
        
        % element calculations
        obj_ref.(obj.elementList{j})(i) = obj_ref.(obj.elementList{j})(i).differential();
        
        % global assembly
        gdof = obj.(obj.elementList{j})(i).gdof;
        obj.KD_G(gdof,gdof)=obj.KD_G(gdof,gdof) + obj_ref.(obj.elementList{j})(i).kd;
    end
end

%% Matrix design derivatives
if nargout > 1
    for dv = 1:ndv
        obj_prime(dv).KD_G = spalloc(obj.ndof,obj.ndof,20*obj.ndof);
        for j = 1:size(obj.elementList,2)
            for i = 1:size(obj.(obj.elementList{j}),2)
                [~,obj_ref_prime(dv).(obj.elementList{j})(i)] = ...
                    differential(obj_ref.(obj.elementList{j})(i),obj_ref_prime(dv).(obj.elementList{j})(i));
                % global assembly
                gdof = obj.(obj.elementList{j})(i).gdof;
                obj_prime(dv).KD_G(gdof,gdof)=obj_prime(dv).KD_G(gdof,gdof) + obj_ref_prime(dv).(obj.elementList{j})(i).kd;
            end
        end
    end
end


%% Solve
if nargout < 2
    [obj.u,obj.eVal] = legacy.SOL_105_CoFE(obj.K_G,obj.KD_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,obj.ndof);
else
    % Response & Design derivatives
    [obj.u,obj.eVal,u_prime,eVal_prime] = legacy.SOL_105_CoFE(...
        obj.K_G,obj.KD_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,...
        obj.ndof,d([obj_prime.K_G]),[obj_prime.KD_G],...
        d([obj_prime.Gm]));
    
    % loop through design varaiables
    for dv = 1:ndv
        obj_prime(dv).u = u_prime(:,:,dv);
        obj_prime(dv).eVal = eVal_prime(:,dv);
    end
end

%% Element Recovery
if obj.CASE.RECOVER == 1
    if nargout < 2
        obj = recover(obj);
    else
        [obj,obj_prime] = recover(obj,obj_prime);
    end
end
