function [err,high_dim_mat] = parc_info_loss(leafs,sc)

max_leaf = size(sc,1);
labels = 1:max_leaf; 
not_leafs = setdiff(labels,leafs); 
idx = 1:max_leaf; 
idx(not_leafs) = 1:length(not_leafs); 
idx(leafs) = length(not_leafs)+1; 

high_dim_mat = sc; 

if size(idx,1) < size(idx,2)
    idx = idx.'; 
end 

for id = unique(idx).' 
    
    group = idx == id; 
    not_group = ~group; 

    if (length(group) < 2)
        continue 
    end
    
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

    

end
high_dim_mat = high_dim_mat - diag(diag(high_dim_mat)); 
%keyboard
err = (high_dim_mat - sc).^2; 
err = sum(err(:)); 

end
