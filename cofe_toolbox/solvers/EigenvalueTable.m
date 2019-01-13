% Class for Eigenvalue Tables
% Anthony Ricciardi
%
classdef EigenvalueTable
    
    properties
        eigenvalue % [nModes,1 double]
        generalizedMass % [nModes,1 double]
        generalizedStiffness % [nModes,1 double]
    end
    properties (Dependent = true)
        frequency
        angularFrequency
    end
    methods
        function obj = EigenvalueTable(eigenvalue,generalizedMass,generalizedStiffness)
            obj.eigenvalue = eigenvalue;
            obj.generalizedMass = generalizedMass;
            obj.generalizedStiffness = generalizedStiffness;
        end
        function frequency = get.frequency(obj)
            frequency=sqrt(obj.eigenvalue)./(2*pi);
        end
        function angularFrequency = get.angularFrequency(obj)
            angularFrequency=sqrt(obj.eigenvalue);
        end
        function echo(obj,fid)
            fprintf(fid,'                                    R E A L   E I G E N V A L U E S\n');
            fprintf(fid,'   MODE          EIGENVALUE            RADIANS             CYCLES            GENERALIZED         GENERALIZED\n');
            fprintf(fid,'    NO.                                                                         MASS              STIFFNESS\n');
            fprintf(fid,'%9d%20E%20E%20E%20E%20E\n',[(1:size(obj.eigenvalue,1))',obj.eigenvalue,obj.angularFrequency,obj.frequency,obj.generalizedMass,obj.generalizedStiffness]' );
        end
    end
end
