function [obj,obj_prime]= analysis(obj,obj_prime)

%% assemble
if nargin < 2
    obj = obj.assemble();
end

% assembly must already be complete for design cases
if nargin > 1
    ndv = size(obj_prime,2);
end

%% SOL 101 - Linear Statics
if obj.CASE.SOL == 101 || obj.CASE.SOL == 105
    
    % Displacements
    if nargout < 2
        obj.x = legacy.SOL_101_CoFE(obj.K_G,obj.Gm,obj.p,obj.n,obj.m,obj.nf_g,obj.nf_n);
    else
        % Displacements & Design derivatives 
        [obj.x,x_prime] = legacy.SOL_101_CoFE(obj.K_G,obj.Gm,obj.p,...
                obj.n,obj.m,obj.nf_g,obj.nf_n,d([obj_prime.K_G]),...
                d([obj_prime.Gm]),d([obj_prime.p]));
        % loop through design varaiables
        for dv = 1:ndv
            obj_prime(dv).x = x_prime(:,dv);
        end
        clear x_prime
    end
    
    % Element Recovery
    if isfield('obj.CASE','RECOVER') == 0
        obj.CASE.RECOVER = 1;
    end
    
    if obj.CASE.RECOVER == 1 || obj.CASE.SOL == 105
        
        for j = 1:size(obj.recoverList,2)
            placeholderObj = obj.(obj.recoverList{j});
            for i = 1:size(placeholderObj,2)
                placeholderObj(i) = placeholderObj(i).recover(obj.gnum2gdof,obj.x);
            end
            obj.(obj.recoverList{j}) = placeholderObj;
            clear placeholderObj
        end
        
        % Recovery design derivatives
        if nargout > 1
            for dv = 1:ndv
                for j = 1:size(obj.recoverList,2)
                    placeholderObj = obj.(obj.recoverList{j}); % placeholder speeds code up rather than direct indexing
                    placeholderObjPrime = obj_prime(dv).(obj.recoverList{j});
                    for i = 1:size(placeholderObj,2)
                        [~,placeholderObjPrime(i)] = ...
                            recover(placeholderObj(i),obj.gnum2gdof,obj.x,placeholderObjPrime(i),obj_prime(dv).x);
                    end
                end
                obj_prime(dv).(obj.recoverList{j}) = placeholderObjPrime;
                clear placeholderObj
                clear placeholderObjPrime
            end
        end
        
    end
    
%% SOL 105 - Buckling Modes
    if obj.CASE.SOL == 105
        
        % determine number of roots desired from EIGRL input cooresponding to
        % the METHOD specified in the case 
        assert(isempty(obj.CASE.METHOD) == 0,'fem.CASE.METHOD must be specified for SOL = 105 cases.');
        assert(isempty(obj.EIGRL) == 0,'An EIGRL entry must be specified for SOL = 105 cases.');
        obj.ND = obj.EIGRL(obj.CASE.METHOD == [obj.EIGRL.SID]).ND;
        
        
        % differential stiffness matrix
        obj.KD_G = spalloc(obj.ndof,obj.ndof,20*obj.ndof);

        % Loop through element types
        for j = 1:size(obj.elementList,2)
            for i = 1:size(obj.(obj.elementList{j}),2)

                % element calculations
                obj.(obj.elementList{j})(i) = obj.(obj.elementList{j})(i).differential(obj.(obj.elementList{j})(i));
                
                % global assembly
                gdof = obj.(obj.elementList{j})(i).gdof;
                obj.KD_G(gdof,gdof)=obj.KD_G(gdof,gdof) + obj.(obj.elementList{j})(i).kd;
            end
        end
        
        % Design derivatives
        if nargout > 1
            for dv = 1:ndv
                obj_prime(dv).KD_G = spalloc(obj.ndof,obj.ndof,20*obj.ndof);
                for j = 1:size(obj.elementList,2)
                    for i = 1:size(obj.(obj.elementList{j}),2)
                        [~,obj_prime(dv).(obj.elementList{j})(i)] = ...
                            differential(obj.(obj.elementList{j})(i),obj_prime(dv).(obj.elementList{j})(i));
                        
                        % global assembly
                        gdof = obj.(obj.elementList{j})(i).gdof;
                        obj_prime(dv).KD_G(gdof,gdof)=obj_prime(dv).KD_G(gdof,gdof) + obj_prime(dv).(obj.elementList{j})(i).kd;
                    end
                end
            end
        end
        
        
        % Solve
        if nargout < 2
            [obj.xb,obj.Db] = legacy.SOL_105_CoFE(obj.K_G,obj.KD_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,obj.ndof);
        else
            % Response & Design derivatives
            [obj.xb,obj.Db,xb_prime,Db_prime] = legacy.SOL_105_CoFE(...
            obj.K_G,obj.KD_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,...
                obj.ndof,d([obj_prime.K_G]),[obj_prime.KD_G],...
                d([obj_prime.Gm]));
            
            % loop through design varaiables
            for dv = 1:ndv
                obj_prime(dv).xb = xb_prime(:,:,dv);
                obj_prime(dv).Db = Db_prime(:,dv);
            end
            clear xb_prime Db_prime
        end
    end

%% SOL 103 - Vibration Modes
elseif obj.CASE.SOL == 103
    
    % determine number of roots desired from EIGRL input cooresponding to
    % the METHOD specified in the case control
    assert(isempty(obj.CASE.METHOD) == 0,'fem.CASE.METHOD must be specified for SOL = 103 cases.');
    assert(isempty(obj.EIGRL) == 0,'An EIGRL entry must be specified for SOL = 103 cases.');
    obj.ND = obj.EIGRL(obj.CASE.METHOD == [obj.EIGRL.SID]).ND;
    
    % solve
    if nargout < 2
        [obj.xm,obj.wHz] = legacy.SOL_103_CoFE(obj.K_G,obj.M_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,obj.ndof);
    else
        % Displacements & Design derivatives
        [obj.xm,obj.wHz,xm_prime,wHz_prime] = legacy.SOL_103_CoFE(...
            obj.K_G,obj.M_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,...
            obj.ndof,d([obj_prime.K_G]),d([obj_prime.M_G]),...
            d([obj_prime.Gm]));

        % loop through design varaiables
        for dv = 1:ndv
            obj_prime(dv).xm = xm_prime(:,:,dv);
            obj_prime(dv).wHz = wHz_prime(:,dv);
        end
        clear xm_prime wHz_prime
    end
    
    
%% Otherwise
else
    error('FEM.CASE.SOL should be set to 101, 103, or 105.')
end

end