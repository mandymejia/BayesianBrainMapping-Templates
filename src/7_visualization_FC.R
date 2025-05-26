template_files <- list.files(
    path = file.path(dir_data, "template_rds"),
    pattern = "^template_.*\\.rds$", 
    full.names = TRUE
    )

get_template_title <- function(base_name) {
  if (grepl("yeo17", base_name, ignore.case = TRUE)) {
    gsr <- if (grepl("GSRT", base_name)) {
      "GSR = TRUE"
    } else if (grepl("GSRF", base_name)) {
      "GSR = FALSE"
    } else {
      "GSR = ?"
    }
    return(paste0("Yeo17 Template (", gsr, ")"))
  }

  ic_match <- regmatches(base_name, regexpr("\\d+ICs", base_name))
  nIC <- gsub("ICs", "", ic_match)
  
  gsr <- if (grepl("GSRT", base_name)) {
    "GSR = TRUE"
  } else if (grepl("GSRF", base_name)) {
    "GSR = FALSE"
  } else {
    "GSR=?"
  }
  
  paste0("GICA ", nIC, " ICs (", gsr, ")")
}

for (file in template_files) {
    template <- readRDS(file)
    base_name <- tools::file_path_sans_ext(basename(file))
    # Number of ICs
    Q <- dim(template$template$mean)[2]
    plot_title <- get_template_title(base_name)
    
    # FC Cholesky 
    template_FC_mean_Cholesky <- template$template$FC_Chol$FC_samp_mean
    template_FC_var_Cholesky <- template$template$FC_Chol$FC_samp_var
    zlim_FC <- c(-0.8, 0.8)
    diag(template_FC_mean_Cholesky) <- diag(template_FC_var_Cholesky) <- NA

    # Save as PDF (2 pages)
    pdf(file.path(dir_data, paste0(base_name, "_FC_Cholesky.pdf")), height=5, width=5.5)
    plot_FC(template_FC_mean_Cholesky, zlim=zlim_FC, title = paste0(plot_title, "\nCholesky FC Template Mean"))
    plot_FC(sqrt(template_FC_var_Cholesky), zlim=c(0.1, 0.3), cols = viridis(12), title = paste0(plot_title, "\nCholesky FC Template SD"))
    dev.off()

    # Save as png (2 images)
    png(file.path(dir_data, paste0(base_name, "_FC_Cholesky_mean.png")), height = 550, width = 600)
    plot_FC(template_FC_mean_Cholesky, zlim = zlim_FC, title = paste0(plot_title, "\nCholesky FC Template Mean"))
    dev.off()

    png(file.path(dir_data, paste0(base_name, "_FC_Cholesky_sd.png")), height = 550, width = 600)
    plot_FC(sqrt(template_FC_var_Cholesky), zlim = c(0.1, 0.3), cols = viridis(12), title = paste0(plot_title, "\nCholesky FC Template SD"))
    dev.off()

    # FC Inverse-Wishart
    template_FC_mean_InverseWishart <- template$template$FC$psi/(template$template$FC$nu - Q - 1)
    template_FC_var_InverseWishart <- template_FC_mean_InverseWishart*0
    for(q1 in 1:Q){
        for(q2 in 1:Q){
            template_FC_var_InverseWishart[q1,q2] <- templateICAr:::IW_var(template$template$FC$nu, Q, template_FC_mean_InverseWishart[q1,q2], template_FC_mean_InverseWishart[q1,q1], template_FC_mean_InverseWishart[q2,q2])
        }
    }
    diag(template_FC_mean_InverseWishart) <- diag(template_FC_var_InverseWishart) <- NA

    # Save as PDF (2 pages)
    pdf(file.path(dir_data, paste0(base_name, "_FC_InverseWishart.pdf")), height=5, width=5.5)
    plot_FC(template_FC_mean_InverseWishart, zlim=zlim_FC, title = paste0(plot_title, "\nInverse-Wishart FC Template Mean"))
    plot_FC(sqrt(template_FC_var_InverseWishart), zlim=c(0.1, 0.3), cols = viridis(12), title = paste0(plot_title, "\nInverse-Wishart FC Template SD"))
    dev.off()

    # Save as png (2 images)
    png(file.path(dir_data, paste0(base_name, "_FC_InverseWishart_mean.png")), height = 550, width = 600)
    plot_FC(template_FC_mean_InverseWishart, zlim = zlim_FC, title = paste0(plot_title, "\nInverse-Wishart FC Template Mean"))
    dev.off()

    png(file.path(dir_data, paste0(base_name, "_FC_InverseWishart_sd.png")), height = 550, width = 600)
    plot_FC(sqrt(template_FC_var_InverseWishart), zlim = c(0.1, 0.3), cols = viridis(12), title = paste0(plot_title, "\nInverse-Wishart FC Template SD"))
    dev.off()
}
