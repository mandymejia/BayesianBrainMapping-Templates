# Setup

# Download packages
# install.packages("ciftiTools")         
# install.packages("templateICAr")       
# install.packages("fMRIscrub")          
# install.packages("fMRItools")          
# install.packages("viridis")
# devtools::install_github("mandymejia/fMRIscrub", "14.0") 

# Load packages
library(ciftiTools)      # version 0.17.4
library(templateICAr)    # version 0.9.1 
library(fMRIscrub)       # version 0.14.7 
library(fMRItools)       # version 0.5.3
library(viridis)         # version 0.6.5 

# Set CIFTI Workbench path
# TODO: download connectome workbench if not downloaded already and modify path below
# wb_path <- "/N/u/ndasilv/Quartz/Downloads/workbench"
# locally
wb_path <- "~/Downloads/workbench"
ciftiTools.setOption("wb_path", wb_path) 

# Set up paths
# dir_project <- "/N/u/ndasilv/Quartz/Documents/GitHub/BayesianBrainMapping-Templates"
# locally
dir_project <- "~/Documents/StatMIND/BayesianBrainMapping-Templates"
dir_HCP <- "/N/project/hcp_dcwan"
dir_results <- "/N/project/brain_prediction"
dir_personal <- "/N/u/ndasilv/Quartz" #[Nohelia] -- this is not used (used in the estimate_and_export_template function to access the final list of subjects (in personal directory of slate since it contains subjects using the restricted data)
dir_data <- file.path(dir_project, "data")
HCP_unrestricted_fname <- file.path(dir_project, "data", "unrestricted_HCP_demographics.csv")
HCP_restricted_fname <- "..."

# Read CSV
HCP_unrestricted <- read.csv(HCP_unrestricted_fname)
HCP_restricted <- read.csv(HCP_restricted_fname)

# All subject IDS
subject_ids <- HCP_unrestricted$Subject

# Constants
fd_lag_HCP <- 4 
fd_cutoff <- .5 # Motion scrubbing threshold
TR_HCP <- .72 # Repetition time 
nT_HCP <- 1200 # Timepoints for each resting state scan
min_total_sec <- 600 # Minimum duration of time series after scrubbing (600 sec = 10 min)
tr_resp_HCP <- .72 # [Nohelia -- do we need this to be a separate var from TR_HCP?]

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


