# Continue filtering subjects
# Balance sex within each age group

for (encoding in c("LR", "RL", "combined")) {
    # From unrestricted data get only the rows that correspond to the valid subject IDs after FD correction and unrelated filtering

    # [TO DO] FORMALIZE THIS SO IT AUTOMATICALLY CHECKS IF THE RESTRICTED DATA IS AVAILABLE
  
    # If skipping step 2 (no access to restricted data / not filtering by unrelated):
    # filtered_unrestricted <- HCP_unrestricted[HCP_unrestricted$Subject %in% get(sprintf("valid_%s_subjects_FD", encoding)), ]
    # Otherwise, if filtering to only unrelated subjects (requires restricted data):
    filtered_unrestricted <- HCP_unrestricted[HCP_unrestricted$Subject %in% get(sprintf("valid_%s_subjects_unrelated", encoding)), ]

    filtered_unrestricted$Age <- as.factor(filtered_unrestricted$Age)
    for (aa in seq_along(levels(filtered_unrestricted$Age))) {
        age_group <- levels(filtered_unrestricted$Age)[aa]
        subset_age <- subset(filtered_unrestricted, Age == age_group)
        gender_counts <- sort(table(subset_age$Gender))

        # Balance only if both genders exist
        if (length(gender_counts) == 2 && diff(gender_counts) != 0) {
            overrepresented_sex <- names(gender_counts)[2]
            to_sample_idx <- which(filtered_unrestricted$Age == age_group & filtered_unrestricted$Gender == overrepresented_sex)
            n_remove <- diff(gender_counts)
            subjects_to_remove_idx <- sample(to_sample_idx, n_remove)
            filtered_unrestricted <- filtered_unrestricted[-subjects_to_remove_idx, ]
        }
    }

    subject_ids_balanced <- filtered_unrestricted$Subject

    # Save new list
    if (encoding == "LR") {
        valid_LR_subjects_balanced <- subject_ids_balanced
    } else if (encoding == "RL") {
        valid_RL_subjects_balanced <- subject_ids_balanced
    } else {
        valid_combined_subjects_balanced <- subject_ids_balanced
    }  
}

# [TO DO] EVERYWHERE, REPLACE DIR_PERSONAL WITH DIR_GITHUB_DATA (OR WHATEVER)

# Save intermediate data in personal directory (due to restricted data)
write.csv(data.frame(subject_id=valid_LR_subjects_balanced), file = file.path(dir_personal, "valid_LR_subjects_balanced.csv"), row.names = FALSE)
write.csv(data.frame(subject_id=valid_RL_subjects_balanced), file = file.path(dir_personal, "valid_RL_subjects_balanced.csv"), row.names = FALSE)
write.csv(data.frame(subject_id=valid_combined_subjects_balanced), file = file.path(dir_personal, "valid_combined_subjects_balanced.csv"), row.names = FALSE)

# Save final list locally as rds
saveRDS(valid_LR_subjects_balanced, file = file.path(dir_personal, "valid_LR_subjects_balanced.rds"))
saveRDS(valid_RL_subjects_balanced, file = file.path(dir_personal, "valid_RL_subjects_balanced.rds"))
saveRDS(valid_combined_subjects_balanced, file = file.path(dir_personal, "valid_combined_subjects_balanced.rds"))