# Yeo 17 visualization
parcellation_all <- readRDS(file.path(dir_data, "outputs", "Yeo17_simplified_mwall.rds"))
parcellation_num <- 17

out_dir <- file.path(dir_data, "outputs", "parcellations_plots", "Yeo17")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

for (parc in parcellation_num) {
  # Copy original parcellation
  copy_parcellation <- parcellation_all
  
  # Get current color of parcellation
  curr_colors <- copy_parcellation$meta$cifti$labels$parcels[copy_parcellation$meta$cifti$labels$parcels$Key == parc,2:4]
  
  # Set all parcellations to white
  copy_parcellation$meta$cifti$labels$parcels[,2:4] = 1
  
  # Set current parcellation to original color
  copy_parcellation$meta$cifti$labels$parcels[copy_parcellation$meta$cifti$labels$parcels$Key == parc,2:4] <- curr_colors
  
  label_name <- rownames(copy_parcellation$meta$cifti$labels$parcels)[copy_parcellation$meta$cifti$labels$parcels$Key == parc]
  plot_title <- paste0("Yeo 17 Network ", label_name, " (#", parc, ")")

  # Plot
  plot(
    copy_parcellation, 
    fname = file.path(out_dir, paste0("Yeo17_", label_name, ".png")),
    title = plot_title
    )
}


