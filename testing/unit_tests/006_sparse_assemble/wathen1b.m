function A = wathen1b (nx,ny)
rand('state',0)
e1 = [6 -6 2 -8;-6 32 -6 20;2 -6 6 -6;-8 20 -6 32];
e2 = [3 -8 2 -6;-8 16 -8 20;2 -8 3 -8;-6 20 -8 16];
e = [e1 e2; e2' e1]/45;
n = 3*nx*ny+2*nx+2*ny+1;
A = sparse(n,n);
RHO = 100*rand(nx,ny);
nn = zeros(8,1);
for j=1:ny
    for i=1:nx
        nn(1) = 3*j*nx+2*i+2*j+1;
        nn(2) = nn(1)-1;
        nn(3) = nn(2)-1;
        nn(4) = (3*j-1)*nx+2*j+i-1;
        nn(5) = 3*(j-1)*nx+2*i+2*j-3;
        nn(6) = nn(5)+1;
        nn(7) = nn(6)+1;
        nn(8) = nn(4)+1;
        em = e*RHO(i,j);
        A (nn,nn) = A (nn,nn) + em ;
    end
end