% Class for GRDSET entries
% Anthony Ricciardi
%
classdef grdset < entry

    % entry data
    properties
        PS
    end
    
    methods
        %%
        function obj = initialize(obj,data)
            CP = set_data('GRDSET','CP',data{3},'int',0 ,0);
            if CP ~= 0; error('Nonzero GRDSET CP not supported.'); end
            CD = set_data('GRDSET','CD',data{7},'int',0);
            if CD ~= 0; error('Nonzero GRDSET CD not supported.'); end
            obj.PS = set_data('GRDSET','PS',data{8},'int',-999); % set to -999 if blank
            SEID = set_data('GRDSET','SEID',data{9},'int',0);
            if SEID ~= 0; error('Nonzero GRDSET SEID not supported.'); end
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'GRDSET,,,,,,,%d\n',obj.PS);
        end
    end
end

