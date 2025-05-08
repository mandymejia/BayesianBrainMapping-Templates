# should it be a fixed zlim?
plot_all_GICA_components <- function(nIC) {
    GICA <- read_cifti(file.path(dir_data, sprintf("GICA_%dIC.dscalar.nii", nIC)))
    Q <- dim(GICA$data$cortex_left)[2]

    out_dir <- file.path(dir_data, "parcellations_plots", sprintf("%dIC", nIC))

    for (i in 1:Q) {
        plot(GICA, idx=i, fname=file.path(out_dir, paste0("GICA_", nIC, "_IC", i, ".png")))
    }
}

# Call function for 15, 25, and 50 IC
plot_all_GICA_components(15)
plot_all_GICA_components(25)
plot_all_GICA_components(50)å