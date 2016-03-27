classdef stressPoint
    % Class used to store stress and optional stress derivative values at a 
    % point.  Dependent stress properties and derivatives (e.g. von Mises) 
    % are calculated real time when prompted using stressPoint.get methods; 
    % dependent stress properties are not stored in memory.  
	%
	% The user is allowed to set the stressPoint.stress_from_analysis 
    % property, but user GetAccess to the property is disallowed.  THE 
    % stressPoint.stress_from_analysis PROPERTY SHOULD ONLY BE DEFINED IN 
    % AN OBJECT IF THE USER INTENDS TO STORE STRESS DERIVATIVES IN THE SAME
    % OBJECT.  The class uses the defined properties in the following 
    % context:
    %
	% IF isempty(stressPoint.stress_from_analysis)
	%     STRESS            = stressPoint.stress
	% ELSE
	%  	  STRESS DERIVATIVE = stressPoint.stress
	%     STRESS            = stressPoint.stress_from_analysis
	% END
	%
	%
	% Additionally: stressPoint.get methods provide values in similar 
    % context:
	%
    % IF isempty(stressPoint.stress_from_analysis)
	%     OUTPUT VALUE            = stressPoint.get.VALUE
	% ELSE
	%  	  OUTPUT VALUE DERIVATIVE = stressPoint.stress.VALUE
	% END
	%
	% The user should define the stressPoint.stress_from_analysis property 
    % before the stressPoint.stress property if stressPoint.stress is 
    % intended to be the stress derivative.  This usage was designed to 
    % preserve the NASTRAN CoFE optimization data storage nomenclature 
    % while introducing a more general stress definition to CoFE elements. 
    % The generalization allows for uniform calculation for dependent 
    % stress quantities (e.g. von Mises) and derivatives; this is intended 
    % to reduce code redundancy and enhance post-processing capabilities.  
	%  
    % Anthony Ricciardi
	% March 2016
    
    %% User properties 
    properties
        stress = []; % Stress (or stress derivative) vector in Voigt notation [s11 s22 s33 s23 s13 s12]
    end
    properties (GetAccess=private) 
        stress_from_analysis = []; % Stress vector in Voigt notation [s11 s22 s33 s23 s13 s12]
        % See comments in header. If provided - implies obj.stress is the stress derivative vector
        % 
    end
    
    %% Object properties stored in memory - not directly accessible by user 
    properties (Access=private)
        s % [real] von Mises stress vector in Voigt notation [s11 s22 s33 s23 s13 s12]
        s_prime % [real] derivative of von Mises stress vector in Voigt notation [ds11 ds22 ds33 ds23 ds13 ds12]
    end
    
    %% Dependent properties - not stored in memory
    
    % accessible properties - should have derivative support
    properties (Dependent=true)
        vonMises % [real] von Mises stress or derivative
        principalStress % [3x1] Principal stresses or derivatives [s1 s2 s3]'
        principalAngle % [real] Principal angle or derivative - this only makes sense for 2D elements
    end
    
    % Inaccessible properties - could grant access, but derivative support
    % should be added beforehand.  
    properties (Dependent=true,GetAccess=private)
        S   % [3x3] Cauchy stress tensor - fully dependent on stress vector
        S_prime  % [3x3] Derivative of Cauchy stress tensor - fully dependent on stress derivative vector
        I1  % [real] First stress invariant
        I2  % [real] Second stress invariant
        I3  % [real] Third stress invariant
        J2  % [real] Second invariant of stress deviator tensor
        J3  % [real] Third invariant of stress deviator tensor
    end   
    
    methods
        %% Set functions
        function obj = set.stress_from_analysis(obj,s_in)
            if size(s_in,1)~=1 || size(s_in,2)~=6
                error('Stress must be input in 1x6 Voigt-notation vector [s11 s22 s33 s23 s13 s12]')
            end
            
            % user property
            obj.stress_from_analysis=s_in;
            
            if isempty(obj.stress) ~= 1
                error('Incorrect useage of stressPoint object.  User should not define stressPoint.stress before stressPoint.stress_from_analysis (if used for optional stress derivative storeage).  See stressPoint class file header for details.')
            end
            % object property
            obj.s=s_in;
        end
        
        
        function obj = set.stress(obj,s_in)
            if size(s_in,1)~=1 || size(s_in,2)~=6
                error('Stress (or stress derivatives) must be input in 1x6 Voigt-notation vector [s11 s22 s33 s23 s13 s12]')
            end
            
            % user property
            obj.stress=s_in;
            
            % object property
            if isempty(obj.stress_from_analysis)
                obj.s=s_in;
            else
                obj.s_prime=s_in;
            end
            
        end
        %%
        
        
        
        %% von Mises stress and derivative
        function svm = get.vonMises(obj)
            if isempty(obj.s_prime)
                % von Mises
                svm = sqrt( .5*((obj.s(1)-obj.s(2))^2+(obj.s(2)-obj.s(3))^2+(obj.s(3)-obj.s(1))^2) ...
                    + 3*(obj.s(4)^2 + obj.s(5)^2 + obj.s(6)^2) );
            else
                % von Mises derivative
                svm = (0.5*(2*(obj.s(1) - obj.s(2))*(obj.s_prime(1) - obj.s_prime(2)) + 2*(obj.s(2) - obj.s(3))*(obj.s_prime(2) - obj.s_prime(3)) + 2*(-obj.s(1) + obj.s(3))*(-obj.s_prime(1) + obj.s_prime(3))) + 3*(2*obj.s(4)*obj.s_prime(4) + 2*obj.s(5)*obj.s_prime(5) + 2*obj.s(6)*obj.s_prime(6)))/(2*sqrt(0.5*((obj.s(1) - obj.s(2))^2 + (obj.s(2) - obj.s(3))^2 + (-obj.s(1) + obj.s(3))^2) + 3*(obj.s(4)^2 + obj.s(5)^2 + obj.s(6)^2)));
            end
        end
        
        
        %% Principal stresses
        function principalStress = get.principalStress(obj)
            
            if isempty(obj.s_prime)
                % lambdas = roots([-1,obj.I1,-obj.I2,obj.I3]);
                % S1 = max(lambdas);
                % S3 = min(lambdas);
                % principalStresses=[S1,obj.I1-S1-S3,S3];
                eVal = eig(obj.S); % faster than algebra
                [~,ind] = sort(real(eVal),'descend');
                principalStress = eVal(ind);
            else
                % Principal stress derivatives
                [eVec,eVal] = eig(obj.S);
                [~,ind] = sort(real(diag(eVal)),'descend');
                principalStress=...
                [(eVec(:,ind(1)).'*obj.S_prime*eVec(:,ind(1)))/(eVec(:,ind(1)).'*eVec(:,ind(1)));...
                 (eVec(:,ind(2)).'*obj.S_prime*eVec(:,ind(2)))/(eVec(:,ind(2)).'*eVec(:,ind(2)));...
                 (eVec(:,ind(3)).'*obj.S_prime*eVec(:,ind(3)))/(eVec(:,ind(3)).'*eVec(:,ind(3)))];
            end
            
        end
        
        %% Principal angles - this only makes sense for 2D elements
        function principleAngle = get.principalAngle(obj)
            if isempty(obj.s_prime)
                principleAngle = .5*atan(2*obj.s(6)/(obj.s(1)-obj.s(2)));
            else
                % Principal angle derivative
                principleAngle = (obj.s(6)*(obj.s_prime(2)-obj.s_prime(1)) + (obj.s(1)-obj.s(2))*obj.s_prime(6))/(obj.s(1)^2 - 2*obj.s(1)*obj.s(2) + obj.s(2)^2 + 4*obj.s(6)^2);
            end
        end

        
        %%
        
        
        
        
        
        
        
        
        
        
        
        %% Stress Tensor
        function stressTensor = get.S(obj)
            stressTensor=[obj.s(1) obj.s(6) obj.s(5); obj.s(6) obj.s(2) obj.s(4); obj.s(5) obj.s(4) obj.s(3)];
        end
        
        %% Stress Tensor Derivative
        function stressTensor_prime = get.S_prime(obj)
            stressTensor_prime=[obj.s_prime(1) obj.s_prime(6) obj.s_prime(5); obj.s_prime(6) obj.s_prime(2) obj.s_prime(4); obj.s_prime(5) obj.s_prime(4) obj.s_prime(3)];
        end
        
        %% Stress invariants
        function invariant_1 = get.I1(obj)
            invariant_1=obj.s(1)+obj.s(2)+obj.s(3); % s = [s11 s22 s33 s23 s13 s12]
            % trace(obj.S)-obj.I1 == 0
        end
        function invariant_2 = get.I2(obj)
            invariant_2 = obj.s(1)*obj.s(2) + obj.s(2)*obj.s(3) + obj.s(1)*obj.s(3) ...
                        - obj.s(4)^2 - obj.s(5)^2 - obj.s(6)^2;
            % .5*(trace(obj.S)^2-trace(obj.S*obj.S))-obj.I2 == 0
        end
        function invariant_3 = get.I3(obj)
            invariant_3 = obj.s(1)*obj.s(2)*obj.s(3) +2*obj.s(4)*obj.s(5)*obj.s(6) ...
                        - obj.s(6)^2*obj.s(3) - obj.s(4)^2*obj.s(1) - obj.s(5)^2*obj.s(2);
            % det(obj.S) - obj.I3 == 0
        end
        
        %% Invariants of the stress deviator tensor
        function invariant_2 = get.J2(obj)
            invariant_2 = (1/6)*((obj.s(1)-obj.s(2))^2+(obj.s(2)-obj.s(3))^2+(obj.s(3)-obj.s(1))^2) ...
                + obj.s(4)^2 + obj.s(5)^2 + obj.s(6)^2;
            % obj.J2 - .5*(trace(obj.S*obj.S)-(1/3)*trace(obj.S)^2) == 0
        end
        function invariant_3 = get.J3(obj)
            invariant_3 = (2/27)*obj.I1^3-(1/3)*obj.I1*obj.I2+obj.I3;
            % obj.J3 - (1/3)*(trace(obj.S*obj.S*obj.S)-trace(obj.S*obj.S)*trace(obj.S)+(2/9)*trace(obj.S)^3) == 0
        end
        
        
        
    end
end

