function [obj,obj_prime]= analysis(obj,obj_prime)

% assembly must already be complete

if nargin > 1
    ndv = size(obj_prime,2);
end

%% SOL 101 - Linear Statics
if obj.CASE.SOL == 101 || obj.CASE.SOL == 105
    
    % Displacements
    if nargout < 2
        obj.u = legacy.SOL_101_CoFE(obj.K_G,obj.Gm,obj.p,obj.n,obj.m,obj.nf_g,obj.nf_n);
    else
        % Displacements & Design derivatives 
        [obj.u,u_prime] = legacy.SOL_101_CoFE(obj.K_G,obj.Gm,obj.p,...
                obj.n,obj.m,obj.nf_g,obj.nf_n,d([obj_prime.K_G]),...
                d([obj_prime.Gm]),d([obj_prime.p]));
        % loop through design varaiables
        for dv = 1:ndv
            obj_prime(dv).u = u_prime(:,dv);
        end
        clear u_prime
    end
    
    % Element Recovery
    if obj.CASE.RECOVER == 1 || obj.CASE.SOL == 105
        
        for j = 1:size(obj.static_recoverList,2)
            placeholderObj = obj.(obj.static_recoverList{j});
            for i = 1:size(placeholderObj,2)
                placeholderObj(i) = placeholderObj(i).recover(obj);
            end
            obj.(obj.static_recoverList{j}) = placeholderObj;
            clear placeholderObj
        end
        
        % Recovery design derivatives
        if nargout > 1
            for dv = 1:ndv
                for j = 1:size(obj.static_recoverList,2)
                    placeholderObj = obj.(obj.static_recoverList{j}); % placeholder speeds code up rather than direct indexing
                    placeholderObjPrime = obj_prime(dv).(obj.static_recoverList{j});
                    for i = 1:size(placeholderObj,2)
                        [~,placeholderObjPrime(i)] = ...
                            recover(placeholderObj(i),obj.gnum2gdof,obj.u,placeholderObjPrime(i),obj_prime(dv).u);
                    end
                    obj_prime(dv).(obj.static_recoverList{j}) = placeholderObjPrime;
                end
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
            [obj.u,obj.Db] = legacy.SOL_105_CoFE(obj.K_G,obj.KD_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,obj.ndof);
        else
            % Response & Design derivatives
            [obj.u,obj.Db,u_prime,Db_prime] = legacy.SOL_105_CoFE(...
            obj.K_G,obj.KD_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,...
                obj.ndof,d([obj_prime.K_G]),[obj_prime.KD_G],...
                d([obj_prime.Gm]));
            
            % loop through design varaiables
            for dv = 1:ndv
                obj_prime(dv).u = u_prime(:,:,dv);
                obj_prime(dv).Db = Db_prime(:,dv);
            end
            clear u_prime Db_prime
        end
    end

%% SOL 103 - Vibration Modes
elseif obj.CASE.SOL == 103
    
    % determine number of roots desired from EIGRL input cooresponding to
    % the METHOD specified in the case control
    if isempty(obj.CASE.METHOD) ~= 0; error('CASE.METHOD must be specified for SOL = 103 cases.'); end
    
    NDn = find(obj.CASE.METHOD == [obj.EIGRL.SID]);
    if size(NDn,2)~=1; error(['There should be one and only one EIGRL with SID = ',num2str(obj.CASE.METHOD),'']); end
    obj.ND = obj.EIGRL(NDn).ND;
    clear NDn
    
    % solve
    if nargout < 2
        [obj.u,obj.wHz] = legacy.SOL_103_CoFE(obj.K_G,obj.M_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,obj.ndof);
        
        if obj.CASE.RECOVER == 1
            for j = 1:size(obj.static_recoverList,2)
                placeholderObj = obj.(obj.static_recoverList{j});
                for i = 1:size(placeholderObj,2)
                    placeholderObj(i) = placeholderObj(i).recover(obj);
                end
                obj.(obj.static_recoverList{j}) = placeholderObj;
                clear placeholderObj
            end
        end
        
        
    else
        % Displacements & Design derivatives
        [obj.u,obj.wHz,u_prime,wHz_prime] = legacy.SOL_103_CoFE(...
            obj.K_G,obj.M_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,...
            obj.ndof,d([obj_prime.K_G]),d([obj_prime.M_G]),...
            d([obj_prime.Gm]));

        % loop through design varaiables
        for dv = 1:ndv
            obj_prime(dv).u = u_prime(:,:,dv);
            obj_prime(dv).wHz = wHz_prime(:,dv);
        end
        clear u_prime wHz_prime
    end
    
    
%% Otherwise
else
    error('FEM.CASE.SOL should be set to 101, 103, or 105.')
end

end