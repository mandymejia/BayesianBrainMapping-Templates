template_files <- list.files(
    path ="~/Documents/StatMIND/Data/template_rds", 
    pattern = "^template_.*\\.rds$", 
    full.names = TRUE
    )

for (file in template_files) {
    template <- readRDS(file)
    base_name <- tools::file_path_sans_ext(basename(file))
    # Number of ICs
    Q <- dim(template$template$mean)[2]
    
    # FC Cholesky
    template_FC_mean_Cholesky <- template$template$FC_Chol$FC_samp_mean
    template_FC_var_Cholesky <- template$template$FC_Chol$FC_samp_var
    pdf(file.path(dir_data, paste0(base_name, "_FC_Cholesky.pdf")), height=5, width=5.5)
    zlim_FC <- c(-0.8, 0.8)
    diag(template_FC_mean_Cholesky) <- diag(template_FC_var_Cholesky) <- NA
    plot_FC(template_FC_mean_Cholesky, zlim=zlim_FC, title = "Cholesky FC Template Mean")
    plot_FC(sqrt(template_FC_var_Cholesky), zlim=c(0.1, 0.3), cols = viridis(12), title = "Cholesky FC Template SD")
    dev.off()

    # FC Inverse-Wishart
    template_FC_mean_InverseWishart <- template$template$FC$psi/(template$template$FC$nu - Q - 1)
    template_FC_var_InverseWishart <- template_FC_mean_InverseWishart*0
    for(q1 in 1:Q){
        for(q2 in 1:Q){
            template_FC_var_InverseWishart[q1,q2] <- templateICAr:::IW_var(template$template$FC$nu, Q, template_FC_mean_InverseWishart[q1,q2], template_FC_mean_InverseWishart[q1,q1], template_FC_mean_InverseWishart[q2,q2])
        }
    }
    pdf(file.path(dir_data, paste0(base_name, "_FC_InverseWishart.pdf")), height=5, width=5.5)
    diag(template_FC_mean_InverseWishart) <- diag(template_FC_var_InverseWishart) <- NA
    plot_FC(template_FC_mean_InverseWishart, zlim=zlim_FC, title = "Inverse-Wishart FC Template Mean")
    plot_FC(sqrt(template_FC_var_InverseWishart), zlim=c(0.1, 0.3), cols = viridis(12), title = "Inverse-Wishart FC Template SD")
    dev.off()
}
