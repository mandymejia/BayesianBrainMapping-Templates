template_files <- list.files(
    path ="~/Documents/StatMIND/Data/template_rds", 
    pattern = "^template_.*\\.rds$", 
    full.names = TRUE
    )

for (file in template_files) {
    template <- readRDS(file)
    base_name <- tools::file_path_sans_ext(basename(file))
    # Save 4 images for each IC (cortical sd and mean, and subcortical sd and mean)
    plot(template, fname=file.path(dir_data, base_name), idx = 1:dim(template$template$mean)[2])
}
