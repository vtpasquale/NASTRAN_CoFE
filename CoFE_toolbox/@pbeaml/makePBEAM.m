function obj = makePBEAM(obj)
switch obj.TYPE
    case 'BAR'
        b = obj.DIM1;
        h = obj.DIM2;
        obj.A = b*h;
        obj.I1 = b.*h.^3./12;
        obj.I2 = b.^3.*h./12;
        
        % torsion
        % aa is the length of the long side
        % bb is the length of the short side
        if b >= h; aa = b; bb = h;
        else aa = h; bb = b;
        end
        obj.J = aa.*bb.^3.*(1./3-.21.*bb./aa.*(1-bb.^4./(12.*aa.^4)));
        % end torsion
        
        obj.K1 = 5./6;
        obj.K2 = 5./6;
        
        obj.C1 = h./2;
        obj.C2 = b./2;
        obj.D1 =-h./2;
        obj.D2 = b./2;
        obj.E1 =-h./2;
        obj.E2 =-b./2;
        obj.F1 = h./2;
        obj.F2 =-b./2;
        
    case 'ROD'
        obj.A = pi.*obj.DIM1.^2;        
        obj.I1 = pi./4.*obj.DIM1.^4;
        obj.I2 = pi./4.*obj.DIM1.^4;
        obj.J = pi./2.*obj.DIM1.^4;
        obj.K1 = 8.5716E-01; % Value Nastran uses (8.5716E-01) is inconsistent with Nastran documentation (0.9);
        obj.K2 = 8.5716E-01;
        obj.C1 = obj.DIM1;
        obj.C2 = 0;
        obj.D1 = 0;
        obj.D2 = obj.DIM1;
        obj.E1 =-obj.DIM1;
        obj.E2 = 0;
        obj.F1 = 0;
        obj.F2 =-obj.DIM1;
        
    otherwise
        error(['PBEAML TYPE ',obj.TYPE,' not supported'])
end
if obj.A <= 0; error('A < 0, there is an issues with PBEAML.'); end
end