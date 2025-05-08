# Need to calculate for each subject, each session, and each encoding the FD (using fMRIscrub)
# The mean FD and time is computed for each session individual for one encoding, needs to be for both sessions <0.1 and time >10 min in order to keep the subject for that enconding
# We are going to do one template for LR, another for RL, and another for combined (need a total of 3 list of valid subjects)

for (subject in subject_ids) {
    for (encoding in c("LR", "RL")) {

        session_pass <- c()

        for (session in c("REST1", "REST2")) {
            # TODO: add dir_HCP
            path <- sprintf("/N/project/hcp_dcwan/%s/MNINonLinear/Results/rfMRI_%s_%s/Movement_Regressors.txt", subject, session, encoding)

            # If file does not exist automatically false
            if (!file.exists(path)) {
                session_pass <- c(session_pass, FALSE)
                next
            }

            X <- as.matrix(read.table(path))

            # fMRIscrub dev branch 14.0 needed as of now to have the resp filter option
            fd <- FD(X=X[,1:6], lag=fd_lag_HCP, cutoff=fd_cutoff, TR_for_resp_filt=tr_resp_HCP)

            mean_fd <- mean(fd$measure, na.rm = TRUE)
            
            # Use logical array to determine the valid volumes (below the cutoff, 0's in array)
            valid_volumes <- sum(!fd$outlier_flag)
            total_time_sec <- TR_HCP * valid_volumes

            # Check condition for filtering
            # passed <- (mean_fd < max_mean_fd) && (total_time_sec >= min_total_sec)
            # No mean fd condition, only total time
            passed <- total_time_sec >= min_total_sec
            session_pass <- c(session_pass, passed)
            
            fd_summary <- rbind(fd_summary, data.frame(
                subject = subject,
                session = session,
                encoding = encoding,
                mean_fd = mean_fd,
                valid_time_sec = total_time_sec
            ))
        }
        # If both rest 1 and rest 2 meet both requirements, add to the list of valid for LR or RL
        if (all(session_pass)) {
            if (encoding == "LR") {
                valid_LR_subjects_FD <- c(valid_LR_subjects_FD, subject)
            } else if (encoding == "RL") {
                valid_RL_subjects_FD <- c(valid_RL_subjects_FD, subject)
            }
        }
    }
}

valid_combined_subjects_FD <- intersect(valid_LR_subjects_FD, valid_RL_subjects_FD)

# Save intermediate data in Slate
write.csv(data.frame(subject_id=valid_LR_subjects_FD), file = file.path(dir_slate, "valid_LR_subjects_FD.csv"), row.names = FALSE)
write.csv(data.frame(subject_id=valid_RL_subjects_FD), file = file.path(dir_slate, "valid_RL_subjects_FD.csv"), row.names = FALSE)
write.csv(data.frame(subject_id=valid_combined_subjects_FD), file = file.path(dir_slate, "valid_combined_subjects_FD.csv"), row.names = FALSE)
write.csv(fd_summary, file = file.path(dir_slate, "fd_summary.csv"), row.names = TRUE)

