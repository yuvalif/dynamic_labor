function x_idx = get_global_param_idx(f_type)
f_type = deblank(f_type);

% load a good starting point
if (strcmp(f_type,'utiity'))
        x_idx = [1:7, 27:32];      %utility + home production parameters both partners
elseif (strcmp(f_type,'wage'))
        x_idx = [8:26,78,79,80];   %wage + job offer probability parameters both partners
elseif (strcmp(f_type,'child'))
        x_idx = [33:43];		   % probability for another child parameter
elseif (strcmp(f_type,'all'))
        x_idx = [1:103];
else
        error(sprintf('unsupported type %s', f_type));
end

