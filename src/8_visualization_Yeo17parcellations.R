# Yeo 17 visualization
parcellation_all <- readRDS(file.path(dir_data, "Yeo17_simplified_mwall.rds"))
parcellation_num <- 1:17

for (parc in parcellation_num) {
  # Copy original parcellation
  copy_parcellation <- parcellation_all
  
  # Get current color of parcellation
  curr_colors <- copy_parcellation$meta$cifti$labels$parcels[copy_parcellation$meta$cifti$labels$parcels$Key == parc,2:4]
  
  # Set all parcellations to white
  copy_parcellation$meta$cifti$labels$parcels[,2:4] = 1
  
  # Set current parcellation to original color
  copy_parcellation$meta$cifti$labels$parcels[copy_parcellation$meta$cifti$labels$parcels$Key == parc,2:4] <- curr_colors
  
  # Plot
  plot(
    copy_parcellation, 
    fname = file.path(dir_data, "parcellations_plots", "Yeo17", paste0("Yeo17_parc_", parc, ".png"))
    )
}


