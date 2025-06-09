# example func call: estimate_and_export_prior("LR", 15, FALSE, dir_personal, dir_data, dir_results, TR_HCP)

# encoding is "LR" / "RL" / "combined"
# nIC is 15 / 25 / 50 or 0 meaning it is yeo17 parcellation
# GSR is TRUE / FALSE
estimate_and_export_prior <- function(
  encoding,
  nIC,
  GSR,
  dir_personal,
  dir_data,
  dir_results,
  TR_HCP
) {
    # Get final list of subjects 
    final_subject_ids <- readRDS(file.path(dir_personal, sprintf("valid_%s_subjects_balanced.rds", "combined")))

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

    cat("Estimating prior for", encoding, "with", nIC, "ICs", "and GSR =", GSR, "\n")

    T_total <- floor(600 / TR_HCP)
    T_scrub_start <- T_total + 1
    scrub_BOLD1 <- replicate(length(BOLD_paths1), T_scrub_start:nT_HCP, simplify = FALSE)
    scrub_BOLD2 <- replicate(length(BOLD_paths2), T_scrub_start:nT_HCP, simplify = FALSE)
    scrub <- list(scrub_BOLD1, scrub_BOLD2)

    if (nIC == 0) {
        # yeo17 parcellation
        GICA <- readRDS(file.path(dir_data, "Yeo17_simplified_mwall.rds"))

        # Include certain ICA (1:17 not 0 or -1 -> medial wall)
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
        saveRDS(prior, file.path(dir_results, sprintf("prior_%s_yeo17_GSR%s.rds", encoding, ifelse(GSR, "T", "F"))))

    } else {
        # HCP IC
        GICA <- file.path(dir_data, sprintf("GICA_%dIC.dscalar.nii", nIC))

        prior <- estimate_prior(
                BOLD = BOLD_paths1,
                BOLD2 = BOLD_paths2,
                template = GICA,
                GSR = GSR,
                TR = TR_HCP,
                hpf = 0.01,
                Q2 = 0,
                Q2_max = NULL,
                verbose = TRUE
                # testing with no scrub and drop_first to see if error persists
                # drop_first = 15,
                # scrub = scrub
                )

        # Save file
        saveRDS(prior, file.path(dir_results, sprintf("prior_%s_%dICs_GSR%s.rds", encoding, nIC, ifelse(GSR, "T", "F"))))

    }

    cat("Saved prior for", encoding, "with", nIC, "ICs", "and GSR =", GSR, "\n")
}