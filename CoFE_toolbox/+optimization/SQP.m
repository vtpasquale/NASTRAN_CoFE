function [x,opts,v,H,status]=sqp(Fun,x0,Opts,vlb,vub,Grd,varargin)
% SQP    Schittkowski's Sequential Quadratic Programming method
%        to find the constrained minimum of a function of several variables
%
% Copyright (c) 2015, Robert A. Canfield. All rights reserved.
%                     See accompanying LICENSE.txt file for conditions.
%
% Schittkowski (1985) "NLPQL: A FORTRAN Subroutine Solving Constrained 
% Nonlinear Programming Problems," Annals Ops. Research, 5:485-500.
%
%  fmincon-compatible problem structure input argument
%          optimtool GUI option "Export to Workspace" dialog box 
%          sends problem information to the MATLAB workspace as a structure
%
%          usage: [x,opts,v,H,status]=sqp( problem )
%
%          input: problem - Data structure with fields:
%                 objective - Objective function	 
%                 x0        - Initial point for x	 
%                 Aineq     - Matrix for linear inequality constraints	 
%                 bineq     - Vector for linear inequality constraints	 
%                 Aeq       - Matrix for linear equality constraints	 
%                 beq       - Vector for linear equality constraints	 
%                 lb	       - Vector of lower bounds	 
%                 ub        - Vector of upper bounds	 
%                 nonlcon   - Nonlinear constraint function 
%                 options   - Options created with optimset
%
%  Optimization Toolbox Version 1-compatible input arguments
%
%         usage: [x,opts,v,H,status]=sqp(Fun,x0,Opts,vlb,vub,Grd,P1,P2,...)
%
%  input: Fun    - string name of a function file which returns the
%                  value of the objective function and a vector of
%                  constraints (i.e. [f,g]=fun(x)).  f is minimized
%                  such that g<zeros(g). Set g=[] for unconstrained.
%         x0     - initial vector of design variables
%         Opts   - (optional) vector of program parameters, or optimset structure
%                  opts(5)  - scale design variables if <0  (or opts.scale)
%                             scale functions if f,g>abs(opts(5))
%                  opts(6)  - change termination criteria  
%                             (or opts.termination)
%                  opts(7)  - maximum function evaluations in line search 
%                             (or opts.MaxLineSearchFun)
%                  opts(14) - max number of function evaluations
%                  opts(15) - max iterations
%                  Type help foptions for more details.
%              Or, a structure following the new fmincon options (optimset)
%                  In addition to optimset options, Opts may contain:
%                  opts.foptions - vector (<=18 length) of old style foptions
%                  opts.LagrangeMultipliers - initial Lagrange multiplier estimate
%                  opts.HessMatrix          - initial positive-definite Hessian estimate
%                  opts.HessFun             - user-supplied Hessian function handle
%                       H=Hessian(x,LagrangeMultipliers)
%         vlb    - (optional) vector of lower bounds on the design
%                  variables
%         vub    - (optional) vector of upper bounds on the design
%                  variables
%         Grd    - (optional) string name of a function file which
%                  returns a vector of function gradients and a
%                  matrix of constraint gradients
%                  (i.e. [fp,gp]=grd(x)).
%         Pn     - (optional) variables directly passed to fun and grd
%                  optional inputs Pn can be skipped by inputing []
%
% output: x      - vector of design variables at the optimal solution
%         opts   - final program parameters
%                  opts(8)  = value of the function at the solution
%                  opts(10) = number of function evaluations
%                  opts(11) = number of gradient evaluations
%                  opts(15) = number of iterations
%         v      - vector of Lagrange multipliers at the solution
%         H      - Hessian at the solution
%         status - Termination status: 0=converged
%
%  Written by:   Capt Mark Spillman and Maj Robert A. Canfield
%                Air Force Institute of Technology, Virginia Tech
%  e-mail:       bob.canfield@vt.edu
%
%  Created:      12/5/94
%  Modified:     9/29/15
%
% The function format is based on the MATLAB function constr.m written
% by Andy Grace of MathWorks, 7/90.  The algorithm is based the FORTRAN
% routine NLPQL written by Klaus Schittkowski, 6/91.
%
%---------------------------------------------------------------------
% Explain the different possible termination criteria
%
% Three different termination criterias can be selected with opts(6):
%
% 1.  If opts(6)=(-1), Schittkowski's criteria is used:
%        KTO=abs(s'*fp)+sum(abs(u.*gv))  <=  opts(3)
%                       SCV=sum(g(g>0))  <=  sqrt(opts(3))
%
% 2.  If opts(6)=1, Andy Grace's criteria is used:
%                     ms=.5*max(abs(s))  <   opts(2)
%                      AG=.5*abs(fp'*s)  <   opts(3)
%                                max(g)  <   opts(4)
%  
% 3.  If opts(6)~=(-1) & opts(6)~=1, the default criteria is used:
%                          max(abs(dx))  <=  opts(2)
%                                   KTO  <=  opts(3)
%                                max(g)  <=  opts(4)
%
% 4.  If opts(6)==2, add Slowed convergence criterion to (3) above.
%                    KTO = norm(Lagrangian gradient)
%---------------------------------------------------------------------
% Explain trouble shooting information
%
% If opts(1)=2 the following information will also be displayed
% when applicable:
%
%     'dH' - Hessian has been perturbed for improved conditioning
%     'aS' - The augmented Lagrangian type Search direction was used
%     'mS' - The modified Search direction problem was used
%     'sx' - Design variables are being scaled
%     'sf' - Objective function is being scaled
%     'sg' - One or more constraint functions scaled
%---------------------------------------------------------------------
% Copyright (c) 2015, Robert A. Canfield. All rights reserved.
%                     Virginia Tech and Air Force Institute of Technology
%                     bob.canfield@vt.edu
%                    <http://www.aoe.vt.edu/people/faculty/canfield.html>
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the "Software"),
% to deal with the Software without restriction, including without 
% limitation the rights to use, copy, modify, merge, publish, distribute, 
% sublicense, and/or sell copies of the Software, and to permit persons 
% to whom the Software is furnished to do so, subject to the following 
% conditions:
% 
% * Redistributions of source code must retain the above copyright notice,
%   this list of conditions and the following disclaimers.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimers in the
%   documentation and/or other materials provided with the distribution.
% 
% * Neither the names of Robert A. Canfield, Virginia Tech, Mark Spillman,
%   Air Force Institute of Technology, nor the names of its contributors 
%   may be used to endorse or promote products derived from this Software 
%   without specific prior written permission.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
% OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
% THE USE OR OTHER DEALINGS WITH THE SOFTWARE. 
%--------------------------------------------------------------------------

type LICENSE.txt