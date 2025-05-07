# example func call: estimate_and_export_template("LR", 15, FALSE, dir_personal, dir_data, dir_slate, TR_HCP)

# encoding is "LR" / "RL" / "combined"
# nIC is 15 / 25 / 50 or 0 meaning it is yeo17 parcellation
# GSR is TRUE / FALSE
estimate_and_export_template <- function(
  encoding,
  nIC,
  GSR,
  dir_personal,
  dir_data,
  dir_slate,
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
        # Concatenating is not supported yet --> for bold 1 path lr and rl with rest 1, for bold 2 path lr and rl with rest 2
        # So stick to one session and use both LR and RL
        BOLD_paths1 <- file.path("/N/project/hcp_dcwan", 
                                final_subject_ids, 
                                "MNINonLinear/Results/rfMRI_REST1_LR/rfMRI_REST1_LR_Atlas_MSMAll_hp2000_clean.dtseries.nii")
    
        BOLD_paths2 <- file.path("/N/project/hcp_dcwan", 
                                final_subject_ids, 
                                "MNINonLinear/Results/rfMRI_REST1_RL/rfMRI_REST1_RL_Atlas_MSMAll_hp2000_clean.dtseries.nii")
    }

    cat("Estimating template for", encoding, "with", nIC, "ICs", "and GSR =", GSR, "\n")

    if (nIC == 0) {
        # yeo17 parcellation
        GICA <- readRDS(file.path(dir_data, "Yeo17_simplified_mwall.rds"))

        # Include certain ICA (1:17 not 0 or -1 -> medial wall)
        valid_keys <- GICA$meta$cifti$labels[[1]]$Key
        inds <- valid_keys[valid_keys > 0]

        template <- estimate_template(
                BOLD = BOLD_paths1,
                BOLD2 = BOLD_paths2,
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
        saveRDS(template, file.path(dir_slate, sprintf("template_%s_yeo17_GSR%s.rds", encoding, ifelse(GSR, "T", "F"))))

    } else {
        # HCP IC
        GICA <- file.path(dir_data, sprintf("GICA_%dIC.dscalar.nii", nIC))

        template <- estimate_template(
                BOLD = BOLD_paths1,
                BOLD2 = BOLD_paths2,
                GICA = GICA,
                GSR=GSR,
                TR = TR_HCP,
                hpf = 0.01,
                Q2 = 0,
                Q2_max = NULL,
                verbose=TRUE
                )

        # Save file
        saveRDS(template, file.path(dir_slate, sprintf("template_%s_%dICs_GSR%s.rds", encoding, nIC, ifelse(GSR, "T", "F"))))

        export_template(
            x = template,
            out_fname = file.path(dir_slate, sprintf("template_%s_%dICs_GSR%s", encoding, nIC, ifelse(GSR, "T", "F")))
        )
    }

    cat("Saved template for", encoding, "with", nIC, "ICs", "and GSR =", GSR, "\n")
}