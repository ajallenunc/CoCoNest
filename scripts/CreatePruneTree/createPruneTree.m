function result = createPruneTree(parc_name,data_path, out_fold,link_method,dist_metric,tree_error,kseq)

    % Output Arguments 
    parc_name
    data_path
    out_fold
    link_method
    dist_metric
    tree_error

    % Load Needed Paths 
    prune_dat = genpath("/work/users/a/a/aallen1/ConConNest/");
    addpath(prune_dat);

    % Get Data High Resolution SC Matrix 
    data_mat = load(data_path).data;

    % Create Tree
    link_mat = linkage(data_mat, link_method, dist_metric); 

    % Prune Tree
    prune_struct = err_comp_prune(link_mat,data_mat, str2func(tree_error));
    prune_struct.link = link_mat; 

    % Save Results 
    save(out_fold + "/TreeResults/"+parc_name+"_prune_struct.mat","prune_struct");

    % Create requested parcellations 
    if size(kseq,1) > size(kseq,2)
        kseq = kseq'
    end

    for k = kseq 
        [~,parc] = tree2IDX(prune_struct,k)
        save(out_fold +"/TreeResults/parcellations/"+parc_name+"_"+string(k)+"_parc.mat","parc")
    end


    result = 1; 

end

