# Estimate Priors using `estimate_prior()`

# Example func call: estimate_and_export_prior("LR", 15, FALSE, dir_data, TR_HCP)
# encoding is "LR" / "RL" / "combined"
# nIC is 15 / 25 / 50 or 0 meaning it is going to use the Yeo17 parcellation
# GSR is TRUE / FALSE
estimate_and_export_prior <- function(
  encoding,
  nIC,
  GSR,
  dir_data,
  TR_HCP
) {
    # Get final list of subjects 
    final_subject_ids <- readRDS(file.path(dir_data, "outputs", "filtering", sprintf("valid_%s_subjects_balanced.rds", encoding)))

    # Construct file paths
    if (encoding == "LR" | encoding == "RL") {
        BOLD_paths1 <- file.path("/N/project/hcp_dcwan", 
                                final_subject_ids, 
                                sprintf("MNINonLinear/Results/rfMRI_REST1_%s/rfMRI_REST1_%s_Atlas_MSMAll_hp2000_clean.dtseries.nii", encoding, encoding))
    
        BOLD_paths2 <- file.path("/N/project/hcp_dcwan", 
                                final_subject_ids, 
                                sprintf("MNINonLinear/Results/rfMRI_REST2_%s/rfMRI_REST2_%s_Atlas_MSMAll_hp2000_clean.dtseries.nii", encoding, encoding))
    } else {
        BOLD_paths1 <- file.path("/N/project/hcp_dcwan", 
                                final_subject_ids, 
                                sprintf("MNINonLinear/Results/rfMRI_REST1_LR/rfMRI_REST1_LR_Atlas_MSMAll_hp2000_clean.dtseries.nii"))
    
        BOLD_paths2 <- file.path("/N/project/hcp_dcwan", 
                                final_subject_ids, 
                                sprintf("MNINonLinear/Results/rfMRI_REST1_RL/rfMRI_REST1_RL_Atlas_MSMAll_hp2000_clean.dtseries.nii"))
    }

    parcellation <- if (nIC == 0) "Yeo17" else sprintf("GICA%d", nIC)
    gsr_label <- ifelse(GSR, "GSR", "noGSR")
    save_dir <- file.path(dir_project, "priors", encoding, parcellation)
    if (!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE)

    cat(sprintf("Estimating prior for encoding: %s , parcellation: %s , %s\n",encoding, parcellation, gsr_label))

    T_total <- floor(600 / TR_HCP)
    T_scrub_start <- T_total + 1
    scrub_BOLD1 <- replicate(length(BOLD_paths1), T_scrub_start:nT_HCP, simplify = FALSE)
    scrub_BOLD2 <- replicate(length(BOLD_paths2), T_scrub_start:nT_HCP, simplify = FALSE)
    scrub <- list(scrub_BOLD1, scrub_BOLD2)

    # Yeo17 parcellation
    if (nIC == 0) {

        GICA <- readRDS(file.path(dir_data, "outputs", "Yeo17_simplified_mwall.rds"))

        # Include certain ICs (1:17 not 0 or -1 -> medial wall)
        valid_keys <- GICA$meta$cifti$labels[[1]]$Key
        inds <- valid_keys[valid_keys > 0]

        prior <- estimate_prior(
                BOLD = BOLD_paths1,
                BOLD2 = BOLD_paths2,
                template = GICA,
                GSR = GSR,
                TR = TR_HCP,
                hpf = 0.01,
                Q2 = 0,
                Q2_max = NULL,
                verbose = TRUE,
                inds = inds,
                brainstructures = c("left", "right"),
                drop_first = 15,
                scrub = scrub
                )
        
        # Save file
        saveRDS(prior, file.path(save_dir, sprintf("prior_%s_%s_%s.rds", encoding, parcellation, gsr_label)))

    # GICA
    } else {

        GICA <- file.path(dir_data, "inputs", sprintf("GICA%d.dscalar.nii", nIC))

        prior <- estimate_prior(
                BOLD = BOLD_paths1,
                BOLD2 = BOLD_paths2,
                template = GICA,
                GSR = GSR,
                TR = TR_HCP,
                hpf = 0.01,
                Q2 = 0,
                Q2_max = NULL,
                verbose = TRUE,
                drop_first = 15,
                scrub = scrub
                )

        # Save file
        saveRDS(prior, file.path(save_dir, sprintf("prior_%s_%s_%s.rds", encoding, parcellation, gsr_label)))
    }

    cat(sprintf("Saved prior for encoding: %s , parcellation: %s , %s\n",encoding, parcellation, gsr_label))
}