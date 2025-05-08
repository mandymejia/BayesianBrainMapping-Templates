# Setup

# Download packages
# TODO: add download packages if not donwloaded already 
# install.packages(...)
# devtools::install_github("mandymejia/fMRIscrub", "14.0") 

# Load packages
library(ciftiTools)
library(templateICAr)
library(fMRIscrub)
library(fMRItools)
library(viridis)

# Set CIFTI Workbench path
# wb_path <- "/N/u/ndasilv/Quartz/Downloads/workbench"
# locally
wb_path <- "~/Downloads/workbench"
ciftiTools.setOption("wb_path", wb_path) 

# Set up paths
# dir_project <- "/N/u/ndasilv/Quartz/Documents/GitHub/BayesianBrainMapping-Templates"
# locally
dir_project <- "~/Documents/StatMIND/BayesianBrainMapping-Templates"
dir_HCP <- "/N/project/hcp_dcwan"
dir_slate <- "/N/project/brain_prediction"
dir_personal <- "/N/u/ndasilv/Quartz"
dir_data <- file.path(dir_project, "data")
HCP_unrestricted_fname <- file.path(dir_project, "data", "unrestricted_HCP_demographics.csv")
#HCP_restricted_fname <- "/N/u/ndasilv/Quartz/Downloads/RESTRICTED_noheliadasilva_4_25_2025_8_33_58.csv"
# locally
HCP_restricted_fname <- "/Users/nohelia/documents/StatMIND/Data/RESTRICTED_noheliadasilva_4_25_2025_8_33_58.csv"
subjects_HCP_fname <- file.path(dir_data, "HCP_subjects_balanced.rds")
HCP_FD_fname <- file.path(dir_data, "HCP_FD.rds")

# Read CSV
HCP_unrestricted <- read.csv(HCP_unrestricted_fname)
HCP_restricted <- read.csv(HCP_restricted_fname)

# All subject IDS
subject_ids <- HCP_unrestricted[[1]]

# Constants
fd_lag_HCP <- 4
fd_cutoff <- .5
TR_HCP <- .72 # repetition time 
nT_HCP <- 1200 # timepoints for each resting state scan
max_mean_fd <- .1
min_total_sec <- 600
tr_resp_HCP <- .72

# Declare empty lists 
valid_LR_subjects_FD <- c()
valid_RL_subjects_FD <- c()

# Initialize table
fd_summary <- data.frame(
  subject = character(),
  session = character(),
  encoding = character(),
  mean_fd = numeric(),
  valid_time_sec = numeric(),
  stringsAsFactors = FALSE
)


