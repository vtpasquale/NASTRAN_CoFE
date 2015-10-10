function [opts,v,H,ComplexStep] = sqpcrkopts( options, numberofvariables )
% Cracks optimization options - converts optimset structure options to old foptions vector.
% Also sets default Lagrange multipliers, v, and Hessian, H if present in structure.
v=[];
H=[];
ComplexStep=false;
if isempty(options)
   opts=foptions;
elseif isstruct(options)
   % Extract non-Optimization Toolbox options first
   ComplexStep=isfield(options,'ComplexStep') && ~isempty(options.ComplexStep) ...
            && strcmpi(options.ComplexStep,'on');
   if isfield(options,'LagrangeMultipliers'), v=options.LagrangeMultipliers; end
   if isfield(options,'HessMatrix'), H=options.HessMatrix; end
   if isfield(options,'Scale'), opts(5)=options.Scale; end
   if isfield(options,'Termination'), opts(6)=options.Termination; end
   if isfield(options,'MaxLineSearchFun'), opts(7)=options.MaxLineSearchFun; end
   if isfield(options,'nec'), opts(13)=options.nec; end
   if isfield(options,'Display'), display=options.Display; else display=[]; end
   if isfield(options,'foptions')
      opts=foptions(options.foptions);
   else
      options=optimset(optimset('fmincon'),options);
      if isempty(display), display=options.Display; end
      switch display
      case 'off'
         opts(1)=0;
      case 'final'
         opts(1)=1;
      case 'iter'
         opts(1)=2;
      case {'Iter', 'debug'}
         opts(1)=3;
      otherwise
         opts(1)=1;
      end
      TolX=optimget(options,'TolX');
      if ~isempty(TolX)
         opts(2)=TolX;
      end
      opts(3)=optimget(options,'TolFun');
      opts(4)=optimget(options,'TolCon');
      opts(9)=strcmpi(optimget(options,'DerivativeCheck'),'on');
      MaxFun = optimget(options,'MaxFunEvals');
      if ischar(MaxFun)
         opts(14)=eval(MaxFun);
      elseif  ~isempty(MaxFun)
         opts(14)=MaxFun;
      end
      MaxIter=optimget(options,'MaxIter');
      if ischar(MaxIter)
         opts(15)=eval(MaxIter);
      elseif  ~isempty(MaxIter)
         opts(15)=MaxIter;
      end
      opts(16)=optimget(options,'DiffMinChange');
      opts(17)=optimget(options,'DiffMaxChange');
      opts=foptions(opts);
   end
else
   opts=foptions(options);
end
if opts(14)==0; opts(14)=100*min(10,numberofvariables); end
if opts(15)==0; opts(15)=10*numberofvariables; end
end