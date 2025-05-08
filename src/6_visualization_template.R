template_files <- list.files(
    path = file.path(dir_data, "template_rds"),
    pattern = "^template_.*\\.rds$", 
    full.names = TRUE
    )


for (file in template_files) {
    template <- readRDS(file)
    base_name <- tools::file_path_sans_ext(basename(file))

    # If Yeo17 template, GICA_parc_table needs to be updated to only reflect the correct number of labels (17)
    if (grepl("yeo17", base_name)) {
        template$GICA_parc_table <- subset(template$GICA_parc_table, template$GICA_parc_table$Key > 0)
    }

    # Save 4 images for each IC (cortical sd and mean, and subcortical sd and mean)
    plot(template, fname=file.path(dir_data, base_name), idx = 1:dim(template$template$mean)[2])
}
