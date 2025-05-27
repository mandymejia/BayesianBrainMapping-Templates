# example func call: estimate_and_export_template("LR", 15, FALSE, dir_personal, dir_data, dir_results, TR_HCP)

# encoding is "LR" / "RL" / "combined"
# nIC is 15 / 25 / 50 or 0 meaning it is yeo17 parcellation
# GSR is TRUE / FALSE
estimate_and_export_template <- function(
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
        # TODO: Implement truncation and dropping frames for this case (not needed now)
        BOLD1 <- file.path("/N/project/hcp_dcwan", 
                                final_subject_ids, 
                                sprintf("MNINonLinear/Results/rfMRI_REST1_%s/rfMRI_REST1_%s_Atlas_MSMAll_hp2000_clean.dtseries.nii", encoding, encoding))
    
        BOLD2 <- file.path("/N/project/hcp_dcwan", 
                                final_subject_ids, 
                                sprintf("MNINonLinear/Results/rfMRI_REST2_%s/rfMRI_REST2_%s_Atlas_MSMAll_hp2000_clean.dtseries.nii", encoding, encoding))
    } else {
        # Implement truncation (10 min) and dropping 15 first frames
        # Lists of final data 
        BOLD1 <- list()
        BOLD2 <- list()
        
        # For each subject, truncate, drop frames, and append to list
        for (subject in final_subject_ids) { 
            # BOLD1 (REST1 LR)
            # Read file 
            BOLD1_path <- file.path("/N/project/hcp_dcwan", 
                                subject, 
                                "MNINonLinear/Results/rfMRI_REST1_LR/rfMRI_REST1_LR_Atlas_MSMAll_hp2000_clean.dtseries.nii")
            BOLD1_data <- read_cifti(BOLD1_path)$data
            # Truncate 10 min
            total_vols <- floor(min_total_sec / TR_HCP)
            # Drop 15 first frames
            drop <- 15
            keep_idx <- (drop + 1):total_vols
            BOLD1_matrix <- rbind(
                BOLD1_data$cortex_left[, keep_idx],
                BOLD1_data$cortex_right[, keep_idx],
                BOLD1_data$subcort[, keep_idx]
            )

            # Append to final list
            BOLD1[[length(BOLD1) + 1]] <- BOLD1_matrix

            # BOLD2 (REST1 RL)
            BOLD2_path <- file.path("/N/project/hcp_dcwan", 
                                subject, 
                                "MNINonLinear/Results/rfMRI_REST1_RL/rfMRI_REST1_RL_Atlas_MSMAll_hp2000_clean.dtseries.nii")
            BOLD2_data <- read_cifti(BOLD2_path)$data
            BOLD2_matrix <- rbind(
                BOLD2_data$cortex_left[, keep_idx],
                BOLD2_data$cortex_right[, keep_idx],
                BOLD2_data$subcort[, keep_idx]
            )
            BOLD2[[length(BOLD2) + 1]] <- BOLD2_matrix

        }
    }

    cat("Estimating template for", encoding, "with", nIC, "ICs", "and GSR =", GSR, "\n")

    if (nIC == 0) {
        # yeo17 parcellation
        GICA <- readRDS(file.path(dir_data, "Yeo17_simplified_mwall.rds"))

        # Include certain ICA (1:17 not 0 or -1 -> medial wall)
        valid_keys <- GICA$meta$cifti$labels[[1]]$Key
        inds <- valid_keys[valid_keys > 0]

        template <- estimate_template(
                BOLD = BOLD1,
                BOLD2 = BOLD2,
                GICA = GICA,
                GSR=GSR,
                TR = TR_HCP,
                hpf = 0.01,
                Q2 = 0,
                Q2_max = NULL,
                verbose=TRUE,
                inds=inds,
                brainstructures=c("left", "right")
                )

        # Save file
        saveRDS(template, file.path(dir_results, sprintf("template_%s_yeo17_GSR%s.rds", encoding, ifelse(GSR, "T", "F"))))

    } else {
        # HCP IC
        GICA <- file.path(dir_data, sprintf("GICA_%dIC.dscalar.nii", nIC))

        template <- estimate_template(
                BOLD = BOLD1,
                BOLD2 = BOLD2,
                GICA = GICA,
                GSR=GSR,
                TR = TR_HCP,
                hpf = 0.01,
                Q2 = 0,
                Q2_max = NULL,
                verbose=TRUE
                )

        # Save file
        saveRDS(template, file.path(dir_results, sprintf("template_%s_%dICs_GSR%s.rds", encoding, nIC, ifelse(GSR, "T", "F"))))

        export_template(
            x = template,
            out_fname = file.path(dir_results, sprintf("template_%s_%dICs_GSR%s", encoding, nIC, ifelse(GSR, "T", "F")))
        )
    }

    cat("Saved template for", encoding, "with", nIC, "ICs", "and GSR =", GSR, "\n")
}