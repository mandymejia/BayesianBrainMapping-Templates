# Plots Functional Connectivity (FC) priors for each prior using both the Cholesky and Inverse-Wishart parameterization

prior_files <- list.files(file.path(dir_project, "priors"), recursive = TRUE)

get_prior_title <- function(base_name, encoding) {
  gsr <- if (grepl("noGSR", base_name)) "noGSR" else "GSR"

  if (grepl("Yeo17", base_name, ignore.case = TRUE)) {
    return(paste0("Yeo17 Prior - ", gsr, " (", encoding, ")"))
  }

  ic_match <- regmatches(base_name, regexpr("GICA\\d+", base_name))
  nIC <- as.numeric(gsub("GICA", "", ic_match))

  paste0("GICA ", nIC, " - ", gsr, " (", encoding, ")")
}

for (file in prior_files) {
    prior <- readRDS(file)
    base_name <- tools::file_path_sans_ext(basename(file))
    relative_path <- dirname(file)
    encoding <- strsplit(relative_path, "/")[[1]][1]

    # Number of ICs
    Q <- dim(prior$template$mean)[2]
    plot_title <- get_prior_title(base_name, encoding)
    
    # FC Cholesky 
    prior_FC_mean_Cholesky <- prior$template$FC_Chol$FC_samp_mean
    prior_FC_var_Cholesky <- prior$template$FC_Chol$FC_samp_var
    zlim_FC <- c(-0.8, 0.8)
    diag(prior_FC_mean_Cholesky) <- diag(prior_FC_var_Cholesky) <- NA

    # Save as PDF (2 pages)
    pdf(file.path(dir_data, "outputs", "priors_plots", relative_path, "FC", paste0(base_name, "_FC_Cholesky.pdf")), height=5, width=5.5)
    plot_FC(prior_FC_mean_Cholesky, zlim=zlim_FC, title = paste0(plot_title, "\nCholesky FC Prior Mean"))
    plot_FC(sqrt(prior_FC_var_Cholesky), zlim=c(0.1, 0.3), cols = viridis(12), title = paste0(plot_title, "\nCholesky FC Prior SD"))
    dev.off()

    # Save as png (2 images)
    png(file.path(dir_data, "outputs", "priors_plots", relative_path, "FC", paste0(base_name, "_FC_Cholesky_mean.png")), height = 550, width = 600)
    plot_FC(prior_FC_mean_Cholesky, zlim = zlim_FC, title = paste0(plot_title, "\nCholesky FC Prior Mean"))
    dev.off()

    png(file.path(dir_data, "outputs", "priors_plots", relative_path, "FC", paste0(base_name, "_FC_Cholesky_sd.png")), height = 550, width = 600)
    plot_FC(sqrt(prior_FC_var_Cholesky), zlim = c(0.1, 0.3), cols = viridis(12), title = paste0(plot_title, "\nCholesky FC Prior SD"))
    dev.off()

    # FC Inverse-Wishart
    prior_FC_mean_InverseWishart <- prior$template$FC$psi/(prior$template$FC$nu - Q - 1)
    prior_FC_var_InverseWishart <- prior_FC_mean_InverseWishart*0
    for(q1 in 1:Q){
        for(q2 in 1:Q){
            prior_FC_var_InverseWishart[q1,q2] <- templateICAr:::IW_var(prior$template$FC$nu, Q, prior_FC_mean_InverseWishart[q1,q2], prior_FC_mean_InverseWishart[q1,q1], prior_FC_mean_InverseWishart[q2,q2])
        }
    }
    diag(prior_FC_mean_InverseWishart) <- diag(prior_FC_var_InverseWishart) <- NA

    # Save as PDF (2 pages)
    pdf(file.path(dir_data, "outputs", "priors_plots", relative_path, "FC", paste0(base_name, "_FC_InverseWishart.pdf")), height=5, width=5.5)
    plot_FC(prior_FC_mean_InverseWishart, zlim=zlim_FC, title = paste0(plot_title, "\nInverse-Wishart FC Prior Mean"))
    plot_FC(sqrt(prior_FC_var_InverseWishart), zlim=c(0.1, 0.3), cols = viridis(12), title = paste0(plot_title, "\nInverse-Wishart FC Prior SD"))
    dev.off()

    # Save as png (2 images)
    png(file.path(dir_data, "outputs", "priors_plots", relative_path, "FC", paste0(base_name, "_FC_InverseWishart_mean.png")), height = 550, width = 600)
    plot_FC(prior_FC_mean_InverseWishart, zlim = zlim_FC, title = paste0(plot_title, "\nInverse-Wishart FC Prior Mean"))
    dev.off()

    png(file.path(dir_data, "outputs", "priors_plots", relative_path, "FC", paste0(base_name, "_FC_InverseWishart_sd.png")), height = 550, width = 600)
    plot_FC(sqrt(prior_FC_var_InverseWishart), zlim = c(0.1, 0.3), cols = viridis(12), title = paste0(plot_title, "\nInverse-Wishart FC Prior SD"))
    dev.off()
}
