prior_files <- list.files(
    path = file.path(dir_data, "priors_rds"),
    pattern = "^prior_.*\\.rds$", 
    full.names = TRUE
    )

get_prior_title <- function(base_name, i, prior) {
  if (grepl("yeo17", base_name, ignore.case = TRUE)) {
    gsr <- if (grepl("GSRT", base_name)) {
      "GSR = TRUE"
    } else if (grepl("GSRF", base_name)) {
      "GSR = FALSE"
    } else {
      "GSR = ?"
    }

    label_name <- rownames(prior$GICA_parc_table)[prior$GICA_parc_table$Key == i]

    return(paste0("Yeo 17 Network ", label_name, " (#", i, ") (", gsr, ")"))
  }

  ic_match <- regmatches(base_name, regexpr("\\d+ICs", base_name))
  nIC <- gsub("ICs", "", ic_match)
  
  gsr <- if (grepl("GSRT", base_name)) {
    "GSR = TRUE"
  } else if (grepl("GSRF", base_name)) {
    "GSR = FALSE"
  } else {
    "GSR = ?"
  }

  paste0("GICA ", nIC, " ICs (", gsr, ") - Component ", i)
}

for (file in prior_files) {
    prior <- readRDS(file)
    base_name <- tools::file_path_sans_ext(basename(file))

    # If Yeo17 template, GICA_parc_table needs to be updated to only reflect the correct number of labels (17)
    if (grepl("yeo17", base_name)) {
        prior$GICA_parc_table <- subset(prior$GICA_parc_table, prior$GICA_parc_table$Key > 0)
    }

    Q <- dim(prior$template$mean)[2]
    # Save 4 images for each IC (cortical sd and mean, and subcortical sd and mean)
    for (i in 1:Q) {
        if (grepl("yeo17", base_name, ignore.case = TRUE)) {
            label_name <- rownames(prior$GICA_parc_table)[prior$GICA_parc_table$Key == i]
            fname <- file.path(dir_data, paste0(base_name, "_", label_name))
        } else {
            fname <- file.path(dir_data, paste0(base_name, "_IC", i))
        }

        plot(
            prior,
            fname = fname,
            idx = i,
            title = get_prior_title(base_name, i, prior)
        )
    }
}
