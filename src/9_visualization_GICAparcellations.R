plot_all_GICA_components <- function(nIC) {
    GICA <- read_cifti(file.path(dir_data, "inputs", sprintf("GICA%d.dscalar.nii", nIC)))
    Q <- dim(GICA$data$cortex_left)[2]

    out_dir <- file.path(dir_data, "outputs", "parcellations_plots", sprintf("GICA%d", nIC))

    for (i in 1:Q) {
        plot_title <- paste0("GICA ", nIC, " - Component ", i)
        plot(GICA, idx=i, fname=file.path(out_dir, paste0("GICA", nIC, "_IC", i, ".png")), title=plot_title)
    }
}

# Call function for 15, 25, and 50 IC
plot_all_GICA_components(15)
plot_all_GICA_components(25)
plot_all_GICA_components(50)