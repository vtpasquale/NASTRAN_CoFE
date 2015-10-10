% membrane strain-displacement matrix
function val = B(obj,xi,eta)
T = TIE(obj,xi,eta);

dNdxzy = T/Jacobian(obj,xi,eta)*...
    [dNdxi(obj,1,xi,eta)  dNdxi(obj,2,xi,eta)  dNdxi(obj,3,xi,eta)  dNdxi(obj,4,xi,eta) ;
     dNdeta(obj,1,xi,eta) dNdeta(obj,2,xi,eta) dNdeta(obj,3,xi,eta) dNdeta(obj,4,xi,eta);
     0                    0                    0                    0                  ];

e1=[dNdxzy(1,1)     0           0;
    0               dNdxzy(2,1) 0; 
    dNdxzy(2,1)     dNdxzy(1,1) 0] * T;

e2=[dNdxzy(1,2)     0           0;
    0               dNdxzy(2,2) 0; 
    dNdxzy(2,2)     dNdxzy(1,2) 0] * T;

e3=[dNdxzy(1,3)     0           0;
    0               dNdxzy(2,3) 0; 
    dNdxzy(2,3)     dNdxzy(1,3) 0] * T;
   
e4=[dNdxzy(1,4)     0           0;
    0               dNdxzy(2,4) 0; 
    dNdxzy(2,4)     dNdxzy(1,4) 0] * T;

val = [e1,e2,e3,e4];
