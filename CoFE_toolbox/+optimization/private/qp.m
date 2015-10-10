function [s,u,status]=qp(H,fp,A,b,vlb,vub,x0,neq,nomsg)
% QP converts old optimization toolbox qp calling sequence to new quadprog
% calling sequence in version 2 and later of the optimization toolbox.
%
% *If using version 1 optimization toolbox, remove this function.*

%--Modifications
%  5/12/06 - Structure options
%   4/4/07 - Increase MaxIter
%   5/6/13 - If A is null, then neq=0
%  9/29/15 - Default quadprog alogorithm instead of deprecated active-set
[nc,nx]=size(A);
neq=min(neq,nc);
MaxIter=max(200,10*min(nx,100));
% Rows of A are partitioned into equality and inequality constraints: p1, p2
p1=1:neq;
p2=neq+1:nc;
% No displayed output (nomsg = -1)
msg={'off','final','iter'};
%%%%%MOSEK%%%%%%
%    path('c:\mosek\4\toolbox\r14sp3',path)
%   options=optimset('Display',msg{nomsg+2},'MaxIter',5000);
%%%%%NORMAL%%%%%%
%options=optimset('Display',msg{nomsg+2},'LargeScale','off','Algorithm','active-set','MaxIter',MaxIter);
options=optimset('quadprog');
options=optimset(options,'Display',msg{nomsg+2},'MaxIter',MaxIter);
if isempty(H)
   [s,f,exitflag,output,LAMBDA]=linprog(fp,A(p2,:),b(p2),A(p1,:),b(p1),vlb,vub,x0,options);
else
   [s,f,exitflag,output,LAMBDA]=quadprog(H,fp,A(p2,:),b(p2),A(p1,:),b(p1),vlb,vub,x0,options);
end
if exitflag>0
   status='ok';
elseif exitflag==0
   status='maximum number of iterations exceeded';
elseif exitflag<0
   status='infeasible, unbounded, or unconverged';
end
u=[];
if exitflag>=0
   if ~isempty(LAMBDA.eqlin),   u=[u;LAMBDA.eqlin(:)]; end
   if ~isempty(LAMBDA.ineqlin), u=[u;LAMBDA.ineqlin(:)]; end
   if ~isempty(vlb),            u=[u;LAMBDA.lower(1:length(vlb))]; end
   if ~isempty(vub),            u=[u;LAMBDA.upper(1:length(vub))]; end
end
%%Added -1 conditions to handle MOSEK exitflags
%  if exitflag==-1
%     status='ok';
%  end
% %%%%%MOSEK%%%%%%%
%  rmpath('c:\mosek\4\toolbox\r14sp3')
%  u = [LAMBDA.eqlin(:); LAMBDA.ineqlin(:); ...
%       LAMBDA.lower(1:length(vlb)); LAMBDA.upper(1:length(vub))];
end