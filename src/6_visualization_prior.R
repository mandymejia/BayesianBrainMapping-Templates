# Plots both the mean and standard deviation components for all priors

# todo: change to priors after all plotting 

prior_files <- list.files(file.path(dir_project, "priors_to_plot"), recursive = TRUE, full.names = TRUE)

get_prior_title <- function(base_name, i, prior, encoding, gsr_status) {

  if (grepl("Yeo17", base_name, ignore.case = TRUE)) {
    label_name <- rownames(prior$GICA_parc_table)[prior$GICA_parc_table$Key == i]
    return(paste0("Yeo 17 Network ", label_name, " (#", i, ") - ", gsr_status, " (", encoding, ")"))
  }
  ic_match <- regmatches(base_name, regexpr("GICA\\d+", base_name))

  nIC <- as.numeric(gsub("GICA", "", ic_match))
  title_str <- paste0("GICA ", nIC, " - Component ", i, " - ", gsr_status, " (", encoding, ")")

  return(title_str)
}

for (file in prior_files) {
  prior <- readRDS(file)

  base_name <- tools::file_path_sans_ext(basename(file))

  parts <- strsplit(base_name, "_")[[1]]
  encoding <- parts[2]      
  parcellation <- parts[3]   
  gsr_status <- parts[4]  

  # If Yeo17 template, GICA_parc_table needs to be updated to only reflect the correct number of labels (17)
  if (grepl("Yeo17", base_name)) {
    prior$GICA_parc_table <- subset(prior$GICA_parc_table, prior$GICA_parc_table$Key > 0)
  }

  Q <- dim(prior$prior$mean)[2]
  # Save 4 images for each IC (cortical sd and mean, and subcortical sd and mean)
  for (i in 1:Q) {
    if (grepl("Yeo17", base_name, ignore.case = TRUE)) {
      label_name <- rownames(prior$GICA_parc_table)[prior$GICA_parc_table$Key == i]
      fname <- file.path(dir_data, "outputs", "priors_plots", parcellation, encoding, gsr_status, paste0(base_name, "_", label_name))
    } else {
      fname <- file.path(dir_data, "outputs", "priors_plots",  parcellation, encoding, gsr_status, paste0(base_name, "_IC", i))
    }

    output_dir <- dirname(fname)
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }
    title <- get_prior_title(base_name, i, prior, encoding, gsr_status)
  
    plot(
      prior,
      fname = fname,
      idx = i,
      title = title
    )
  }
}
