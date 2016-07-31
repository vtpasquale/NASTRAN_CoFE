% Abstract superclass for structure
% Anthony Ricciardi
%
classdef (Abstract) structure < element
    
    properties (Abstract)
        voigtStress % [6 x nm x nrp] Matrix of stress vectors in Voigt notation [[s11 s22 s33 s23 s13 s12]' x nm x nrp], where nm is the number of response modes and nrp is the number of element recovery points.
        voigtStrain % [6 x nm x nrp] Matrix of strain vectors in Voigt notation [[s11 s22 s33 s23 s13 s12]' x nm x nrp], where nm is the number of response modes and nrp is the number of element recovery points.
    end
    properties (GetAccess = private)
        voigtStress_fromAnalysis = []; % = voigtStress, but only defined for FEM_prime objects.
        voigtStrain_fromAnalysis = []; % = voigtStrain, but only defined for FEM_prime objects.
        % Structure classes store stress/strain and optional stress/strain
        % derivative values at all recovery points  Dependent stress/strain
        % properties and derivatives (e.g. von Mises) are calculated real time
        % when prompted using structure.get methods. Dependent stress/strain
        % properties are not stored in memory.
        %
        % The user is allowed to set the structure.voigtStress_fromAnalysis and
        % structure.voigtStrain_fromAnalysis properties, but user GetAccess to
        % the "_fromAnalysis" properties is disallowed.  THE  "_fromAnalysis"
        % PROPERTIES SHOULD ONLY BE DEFINED IN AN OBJECT IF THE USER INTENDS TO
        % STORE STRESS DERIVATIVES IN THE SAME OBJECT.  The class uses the
        % defined properties in the following context:
        %
        % IF isempty(structure.voigtStress_fromAnalysis)
        %     STRESS            = structure.voigtStress
        % ELSE
        %  	  STRESS DERIVATIVE = structure.voigtStress
        %     STRESS            = structure.voigtStress_from_analysis
        % END
        %
        %
        % Additionally, structure.get methods provide values in similar
        % context:
        %
        % IF isempty(structure.voigtStress_from_analysis)
        %     STRESS            = structure.get.voigtStress
        % ELSE
        %  	  STRESS DERIVATIVE = structure.get.voigtStress
        % END
        %
        % structure.voigtStrain is treated an analogous manner.
        %
        % Stress/strain dependent property derivatives (e.g. von Mises) are
        % also treated in an analogous manner.  This usage was designed to
        % preserve the NASTRAN CoFE optimization data storage nomenclature
        % while introducing a more general stress definition to CoFE elements.
        % The generalization allows for uniform calculation for dependent
        % stress quantities and derivatives; this is intended to reduce code
        % redundancy and enhance post-processing capabilities.
        %
    end
    %% Dependent properties - not stored in memory
    % accessible properties - should have derivative support
    properties (Dependent=true)
        vonMisesStress  % [nm x nrp] von Mises stresses or derivatives
        %         principalStress % [3x1] Principal stresses or derivatives [s1 s2 s3]'
        %         principalAngle  % [real] Principal angle or derivative - this only makes sense for 2D elements
    end
    
    %% Abstract Methods
    methods (Abstract)
        element(obj,FEM)
        differential(obj,obj_prime)
        recover(obj,FEM,obj_prime,FEM_prime)
        write_recover(obj_array,fid)
    end
    
    methods
        %% Set functions
        function obj = set.voigtStress_fromAnalysis(obj,s_in)
            if size(s_in,1)~=6
                error('Voigt stress (or stress derivatives) must be a matrix of 6x1 Voigt-notation vectors [[s11 s22 s33 s23 s13 s12]'' x nm x nrp], where nm is the number of response modes and nrp is the number of element recovery points. ')
            end
            
            % user property
            obj.voigtStress_fromAnalysis=s_in;
            
            if isempty(obj.voigtStress) ~= 1
                error('Incorrect useage of structure.voigtStress value.  User should not define structure.voigtStress before structure.voigtStress_fromAnalysis (if used for optional stress derivative storeage).  See structure superclass file header for details.')
            end
        end
        
        function obj = set.voigtStrain_fromAnalysis(obj,s_in)
            if size(s_in,1)~=6
                error('Voigt strain (or strain derivatives) must be a matrix of 6x1 Voigt-notation vectors [[s11 s22 s33 s23 s13 s12]'' x nm x nrp], where nm is the number of response modes and nrp is the number of element recovery points. ')
            end
            
            % user property
            obj.voigtStrain_fromAnalysis=s_in;
            
            if isempty(obj.voigtStrain) ~= 1
                error('Incorrect useage of structure.voigtStrain value.  User should not define structure.voigtStrain before structure.voigtStrain_fromAnalysis (if used for optional strain derivative storeage).  See structure superclass file header for details.')
            end
        end
        
        %% von Mises stresses or derivativees
        function svm = get.vonMisesStress(obj)
            VoigtStress = obj.voigtStress;
            if size(VoigtStress,1)~=6
                error('structure.get.vonMisesStress failed.  structure.voigtStress must be a matrix of 6x1 Voigt-notation vectors [[s11 s22 s33 s23 s13 s12]'' x nm x nrp], where nm is the number of response modes and nrp is the number of element recovery points. ')
            end
            
            nm = size(VoigtStress,2);
            nrp = size(VoigtStress,3);
            svm = zeros(nm,nrp);
            
            if isempty(obj.voigtStress_fromAnalysis)
                % von Mises
                for m = 1:nm
                    for rp = 1:nrp
                        s = VoigtStress(:,m,rp);
                        svm(m,rp) = sqrt( .5*((s(1)-s(2))^2+(s(2)-s(3))^2+(s(3)-s(1))^2) ...
                            + 3*(s(4)^2 + s(5)^2 + s(6)^2) );
                    end
                end
            else
                % von Mises derivative
                VoigtStress_Prime = VoigtStress;
                VoigtStress = obj.voigtStress_fromAnalysis;
                
                for m = 1:nm
                    for rp = 1:nrp
                        s = VoigtStress(:,m,rp);
                        s_prime = VoigtStress_Prime(:,m,rp);
                        svm(m,rp) = (0.5*(2*(s(1) - s(2))*(s_prime(1) - s_prime(2)) + 2*(s(2) - s(3))*(s_prime(2) - s_prime(3)) + 2*(-s(1) + s(3))*(-s_prime(1) + s_prime(3))) + 3*(2*s(4)*s_prime(4) + 2*s(5)*s_prime(5) + 2*s(6)*s_prime(6)))/(2*sqrt(0.5*((s(1) - s(2))^2 + (s(2) - s(3))^2 + (-s(1) + s(3))^2) + 3*(s(4)^2 + s(5)^2 + s(6)^2)));
                    end
                end
                
            end
        end
        
        
        
    end
    
end

