function [err,high_dim_mat] = scTreeFit(descends,sc)

max_leaf = size(sc,1);
labels = 1:max_leaf; 
not_descends = setdiff(labels,descends); 
descends_label = length(not_descends)+1; 

% Create Label Vector
idx = 1:max_leaf; 
idx(not_descends) = 1:length(not_descends); 
idx(descends) = descends_label; 

% Initialize Augmented Matrix
high_dim_mat = zeros(max_leaf,max_leaf); 

if size(idx,1) < size(idx,2)
    idx = idx.'; 
end 

group = idx == descends_label; 
not_group= ~group; 

%% Handle Without Group Connections 
not_group_dat = sc(group,not_group);         
means = mean(not_group_dat,1); % Calculate mean
assign = repmat(means,nnz(group),1); % Fill up matrix with means

high_dim_mat(group,not_group) = assign; 
high_dim_mat(not_group,group) = assign.'; 

%% Handle Within Group Connections 

group_nest = sc(group,group); % Set within cluster connections
if group_nest == 0
    high_dim_mat(group,group) = 0;
else
    high_dim_mat(group,group) = mean(vectorizeMat(group_nest));
end
high_dim_mat(not_group,not_group) = sc(not_group,not_group); 

high_dim_mat = high_dim_mat - diag(diag(high_dim_mat)); 

err = (high_dim_mat - sc).^2; 
err = sum(err(:)); 

end
