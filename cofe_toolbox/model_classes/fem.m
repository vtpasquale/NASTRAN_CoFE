classdef fem
    % Class that defines a finite element model
    
    properties
        
        %% Sets
%         sb % ([:,1] int) Degrees-of-freedom eliminated by single-point constraints that are included in boundary conditions
%         sg % ([:,1] int) Degrees-of-freedom eliminated by single-point constraints that are specified on the PS field on GRID Bulk Data entries.
        s  % ([:,1] int) All degrees-of-freedom eliminated by single point constraints -> sb + sg
        f  % ([:,1] int) Unconstrained (free) structural degrees-of-freedom -> a + o 
        m  % ([:,1] int) All degrees-of-freedom eliminated by multiple constraints
        n  % ([:,1] int) All degrees-of-freedom not constrained by multipoint constraints
        
        %% Matricies
        K
        KD
        M
        G
        
    end
    
    methods
    end
    
end

