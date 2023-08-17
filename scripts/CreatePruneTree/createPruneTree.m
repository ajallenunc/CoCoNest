function result = createPruneTree(data_path, out_fold)

    % Load Needed Paths 
    prune_dat = genpath("/work/users/a/a/aallen1/BrainParc/");
    addpath(prune_dat);

    % Get Data High Resolution SC Matrix 
    data_mat = load(data_path).sc_hr;

    % Create Tree
    link_mat = linkage(data_mat, 'average', 'euclidean'); 

    % Prune Tree
    prune_struct = cost_comp_prune(link_mat,data_mat, @parc_info_loss);

    % Save Results 
    save(out_fold + "concon_prune_struct.mat","prune_struct");

    result = 1; 

end

