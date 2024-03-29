% Class for beam elements.
% Anthony Ricciardi
%
classdef Cbeam < Element
    
    properties
        eid % [uint32] Element identification number.
        pid % [uint32] Property identification number of a PBEAM entry.
        g   % [2,1 uint32] Grid point identification numbers of connection points [GA,GB].
        nu_g   % [3,1 double] Components of orientation vector NU, from GA, in the nodal displacement reference frame at GA.
        
        gdof % [1,12 uint32] indices of global degrees of freedom associated with the element.
        R_eg % [12 x 12 double] rotation matrix from the element reference frame to the nodal displacement reference frame.
        k_e % [12 x 12 double] element stiffness matrix in the element reference frame
        m_e % [12 x 12 double] element mass matrix in the element reference frame
        
        volume % [double] element volume
        mass % [double] element mass
    end
    properties (Constant = true, Hidden = true)
        ELEMENT_TYPE = uint8(2); % [uint8] Element code corresponding to Nastran item codes documentation.
        VTK_CELL_CLASSNAME = 'VtkCellLine'; % [char] Vtk cell classname
        VTK_CELL_TYPE = uint8(3); % [uint8] VTK cell type number
        VTK_RESULT_TYPE = uint8(2); % [uint8] VTK result type number. Same as ELEMENT_TYPE unless result items are shared across ELEMENT_TYPEs.
        HDF5_ELEMENT_FORCE_CLASSNAME = 'Hdf5ElementForceBeam';
        HDF5_STRAIN_CLASSNAME = 'Hdf5ElementStrainBeam';
        HDF5_STRESS_CLASSNAME = 'Hdf5ElementStressBeam';
    end
    properties (Constant = true,Hidden = true)
        PAGE_TITLE = 'B E A M   E L E M E N T S     ( C B E A M )';
        FORCE_ITEMS = {'EndA_Axial','EndA_Shear_1','EndA_Shear_2','EndA_Torque','EndA_Moment_1','EndA_Moment_2',...
                       'EndB_Axial','EndB_Shear_1','EndB_Shear_2','EndB_Torque','EndB_Moment_1','EndB_Moment_2',...
                       'EndA_Grid_ID','EndB_Grid_ID'};
        STRESS_ITEMS = {'EndA_PointC','EndA_PointD','EndA_PointE','EndA_PointF',...
                        'EndB_PointC','EndB_PointD','EndB_PointE','EndB_PointF',...
                        'EndA_Grid_ID','EndB_Grid_ID'};
        STRAIN_ITEMS = {'EndA_PointC','EndA_PointD','EndA_PointE','EndA_PointF',...
                        'EndB_PointC','EndB_PointD','EndB_PointE','EndB_PointF',...
                        'EndA_Grid_ID','EndB_Grid_ID'};
    end
    methods
        function obj=assemble_sub(obj,model)
            
            % Geometry Data
            n1 = model.point.getNode(obj.g(1),model);
            n2 = model.point.getNode(obj.g(2),model);
            obj.gdof = [n1.gdof,n2.gdof];
            p1 = n1.x_0;
            p2 = n2.x_0;
            nu_0 = n1.T_g0.'*obj.nu_g;
            
            % Property and material data
            pty = model.property.getProperty(obj.pid,model,'Pbeam');
            
            % Element matricies
            [T_e0,obj.k_e,obj.m_e,obj.volume,obj.mass] = ...
                getBeamElementMatrices(p1,p2,nu_0,...
                pty.E,pty.G,pty.a,pty.i2,pty.i1,pty.j,pty.rho,pty.nsm,...
                pty.k1,pty.k2,model.coupledMassFlag,true,obj.eid);
            
            % Transformation matrix
            obj.R_eg(10:12,10:12) = T_e0*n2.T_g0.';
            obj.R_eg(7:9,7:9)     = T_e0*n2.T_g0.';
            obj.R_eg(4:6,4:6)     = T_e0*n1.T_g0.';
            obj.R_eg(1:3,1:3)     = T_e0*n1.T_g0.';
        end
        function [force,stress,strain,strainEnergy,kineticEnergy] = recover_sub(obj,u_g,model,returnFlags)
            % INPUTS
            % u_g [nGodf,nVectors double] Response vector in nodal displacement reference frame
            % returnFlags [1,5 logical] [force,stress,strain,strainEnergy,kineticEnergy] 1 -> recover, 0 -> return empty array []
            %
            % OUTPUTS
            % force = [14,nVectors double] Element forces
            %   indices:
            %    [1 |  Beam EndA Axial Force
            %     2 |  Beam EndA Plane1 Shear Force
            %     3 |  Beam EndA Plane2 Shear Force
            %     4 |  Beam EndA Torque
            %     5 |  Beam EndA Plane1 Moment
            %     6 |  Beam EndA Plane2 Moment
            %     7 |  Beam EndB Axial Force
            %     8 |  Beam EndB Plane1 Shear Force
            %     9 |  Beam EndB Plane2 Shear Force
            %    10 |  Beam EndB Torque 
            %    11 |  Beam EndB Plane1 Moment
            %    12 |  Beam EndB Plane2 Moment
            %    13 |  Beam EndA Grid ID (for HDF5) 
            %    14 |  Beam EndB Grid ID (for HDF5) ]
            %
            % stress  = [8,nVectors double] Element stresses
            % strain  = [8,nVectors double] Element strains
            %   indices:
            %    [1 |  End A Long. Stress or Strain at Point C
            %     2 |  End A Long. Stress or Strain at Point D
            %     3 |  End A Long. Stress or Strain at Point E
            %     4 |  End A Long. Stress or Strain at Point F
            %     5 |  End B Long. Stress or Strain at Point C
            %     6 |  End B Long. Stress or Strain at Point D
            %     7 |  End B Long. Stress or Strain at Point E
            %     8 |  End B Long. Stress or Strain at Point F
            %     9 |  Beam EndA Grid ID (for HDF5)
            %    10 |  Beam EndB Grid ID (for HDF5) ]
            %
            % strainEnergy  = [3,nVectors double] Element strain energy
            % kineticEnergy = [3,nVectors double] Element kinetic energy
            %   indices:
            %    [ energy           
            %      energy----------> converted to percent total later by Element.recover()
            %      energyDensity];
            %  kineticEnergy scaled by omega later by Element.recover()
            
            
            
            % Check inputs
            if ~any(returnFlags); error('This function is not intended to be called if no vaules are to be recovered'); end
            
            % Element displacements and forces
            u_e = obj.R_eg*u_g(obj.gdof,:);
            f_e = obj.k_e*u_e;
            nVectors = size(u_e,2);
            
            % Force
            if returnFlags(1)
                force = [-f_e(1:6 ,:);
                          f_e(7:12,:); 
                          double(repmat(obj.g.',[1,nVectors]))];
            else
                force = [];
            end
                        
            % Calcualte stress for stress or strain recovery
            if any(returnFlags(2:3))
                pty = model.property.getProperty(obj.pid,model,'Pbeam');
                [C1,C2,D1,D2,E1,E2,F1,F2]=pty.getStressLocations();
                force2stress = [1/pty.a, 0, 0, 0, C2/pty.i2, -C1/pty.i1;
                                1/pty.a, 0, 0, 0, D2/pty.i2, -D1/pty.i1;
                                1/pty.a, 0, 0, 0, E2/pty.i2, -E1/pty.i1;
                                1/pty.a, 0, 0, 0, F2/pty.i2, -F1/pty.i1];
                s = [-force2stress*f_e(1:6,:);
                      force2stress*f_e(7:end,:)];
            end
            
            % Stress
            if returnFlags(2)
                stress = [s;
                          double(repmat(obj.g.',[1,nVectors]))];
            else
                stress = [];
            end
            
            % Strain
            if returnFlags(3)
                strain = [(1/pty.E)*s;
                          double(repmat(obj.g.',[1,nVectors]))];
            else
                strain = [];
            end
            
            % Strain Energy
            if returnFlags(4)
                strainEnergy0 = .5*diag(u_e.'*f_e).';
                strainEnergy = [strainEnergy0;
                                strainEnergy0;%---> converted to percent total later by Element.recover()
                                (1/obj.volume)*strainEnergy0];
            else
                strainEnergy = [];
            end
            
            % Kinetic Energy (scaled by omega later by Element.recover())
            if returnFlags(5)
                kineticEnergy0 = .5*diag(u_e.'*obj.m_e*u_e).';
                kineticEnergy = [kineticEnergy0;
                                 kineticEnergy0;%---> converted to percent total later by Element.recover()
                                 (1/obj.volume)*kineticEnergy0];
            else
                kineticEnergy = [];
            end
        end % recover_sub()
    end
end