# Plots both the mean and standard deviation components for all priors


# todo: modify to include the enconding too? 

prior_files <- list.files(
    path = file.path(dir_data, "priors"),
    pattern = "^prior_.*\\.rds$", 
    full.names = TRUE
  )

get_prior_title <- function(base_name, i, prior) {
  gsr <- if (grepl("noGSR", base_name)) {
    "noGSR"
  } else {
    "GSR"
  }

  if (grepl("Yeo17", base_name, ignore.case = TRUE)) {
    
    label_name <- rownames(prior$GICA_parc_table)[prior$GICA_parc_table$Key == i]

    return(paste0("Yeo 17 Network ", label_name, " (#", i, ") ", gsr))
  }

  ic_match <- regmatches(base_name, regexpr("GICA\\d+", base_name))
  nIC <-  as.numeric(gsub("GICA", "", ic_match))

  paste0("GICA ", nIC, gsr, " - Component ", i)
}

for (file in prior_files) {
    prior <- readRDS(file)
    base_name <- tools::file_path_sans_ext(basename(file))

    # If Yeo17 template, GICA_parc_table needs to be updated to only reflect the correct number of labels (17)
    if (grepl("Yeo17", base_name)) {
        prior$GICA_parc_table <- subset(prior$GICA_parc_table, prior$GICA_parc_table$Key > 0)
    }

    Q <- dim(prior$template$mean)[2]
    # Save 4 images for each IC (cortical sd and mean, and subcortical sd and mean)
    for (i in 1:Q) {
        if (grepl("Yeo17", base_name, ignore.case = TRUE)) {
            label_name <- rownames(prior$GICA_parc_table)[prior$GICA_parc_table$Key == i]
            fname <- file.path(dir_data, "outputs", "priors_plots", paste0(base_name, "_", label_name))
        } else {
            fname <- file.path(dir_data, "outputs", "priors_plots", paste0(base_name, "_IC", i))
        }

        plot(
            prior,
            fname = fname,
            idx = i,
            title = get_prior_title(base_name, i, prior)
        )
    }
}
