# Setup

# Download packages
# TODO: add packages loaded below if not downloaded already 
# install.packages(...)
# devtools::install_github("mandymejia/fMRIscrub", "14.0") 

# Load packages #[Nohelia] -- can you comment the package version you used next to each package 
library(ciftiTools)
library(templateICAr)
library(fMRIscrub)
library(fMRItools)
library(viridis)

# Set CIFTI Workbench path
# TODO: download connectome workbench if not downloaded already and modify path below
# wb_path <- "/N/u/ndasilv/Quartz/Downloads/workbench"
# locally
wb_path <- "~/Downloads/workbench"
ciftiTools.setOption("wb_path", wb_path) 

# Set up paths
# dir_project <- "/N/u/ndasilv/Quartz/Documents/GitHub/BayesianBrainMapping-Templates"
# locally
dir_project <- "~/Documents/Github/BayesianBrainMapping-Templates"
dir_HCP <- "/N/project/hcp_dcwan"
dir_slate <- "/N/project/brain_prediction" #[Nohelia] -- maybe rename dir_slate to dir_results or something more generic
dir_personal <- "/N/u/ndasilv/Quartz" #[Nohelia] -- this is not used
dir_data <- file.path(dir_project, "data")
HCP_unrestricted_fname <- file.path(dir_project, "data", "unrestricted_HCP_demographics.csv")
#HCP_restricted_fname <- "/N/u/ndasilv/Quartz/Downloads/RESTRICTED_noheliadasilva_4_25_2025_8_33_58.csv"
# locally
HCP_restricted_fname <- "/Users/nohelia/documents/StatMIND/Data/RESTRICTED_noheliadasilva_4_25_2025_8_33_58.csv" #[Nohelia] -- I'd put something dummy here instead of the real path/name 
subjects_HCP_fname <- file.path(dir_data, "HCP_subjects_balanced.rds") #[Nohelia] do we use this?  If so, where is the code to produce it?
HCP_FD_fname <- file.path(dir_data, "HCP_FD.rds") #[Nohelia] do we use this?  If so, where is the code to produce it?

# Read CSV
HCP_unrestricted <- read.csv(HCP_unrestricted_fname)
HCP_restricted <- read.csv(HCP_restricted_fname)

# All subject IDS
subject_ids <- HCP_unrestricted[[1]] #[Nohelia] -- since this is a data frame it's a bit odd to do it with [[[1]]], you can use [,1] or $ instead

# Constants
fd_lag_HCP <- 4 
fd_cutoff <- .5 #motion scrubbing threshold
TR_HCP <- .72 # repetition time 
nT_HCP <- 1200 # timepoints for each resting state scan
max_mean_fd <- .1 # [Nohelia -- do we actually use this?]
min_total_sec <- 600 #minimum duration of time series after scrubbing (600 sec = 10 min)
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


