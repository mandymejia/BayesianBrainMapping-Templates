# Setup

# Download packages
# TODO: add devtools download
# install.packages("ciftiTools")         
# install.packages("templateICAr")       
# devtools::install_github("mandymejia/fMRIscrub", "14.0")          
# install.packages("fMRItools")          
# install.packages("viridis")
# devtools::install_github("mandymejia/BayesBrainMap")

# Load packages
library(ciftiTools)      # version 0.17.4
library(templateICAr)    # version 0.9.1 
library(fMRIscrub)       # version 0.14.7
library(fMRItools)       # version 0.5.3
library(viridis)         # version 0.6.5
library(BayesBrainMap)   # version: 0.11.0 ###TODO: ANOTHER ONE? 

# Set CIFTI Workbench path
# wb_path <- "/N/u/ndasilv/Quartz/Downloads/workbench"
# locally
wb_path <- "~/Downloads/workbench"
ciftiTools.setOption("wb_path", wb_path) 

# Set up paths
dir_HCP <- "/N/project/hcp_dcwan" #location of HCP data on the cluster
#dir_results <- file.path(dir_project, "results")
dir_results <- "/N/project/brain_prediction" #[TO DO] replace with Github subdirectory (add that subdirectory to gitignore)
dir_project <- "~/Documents/StatMIND/BayesianBrainMapping-Templates" #path to the main project folder that contains all code and data (i.e., your local clone of BayesianBrainMapping-Templates)
# dir_project <- "~/Documents/GitHub/BayesianBrainMapping-Templates"
dir_data <- file.path(dir_project, "data")

# HCP_unrestricted_fname <- file.path(dir_project, "data", "unrestricted_HCP_demographics.csv")
# locally
HCP_unrestricted_fname <- file.path(dir_data, "unrestricted_HCP_demographics.csv")
# HCP_restricted_fname <- file.path("~/Downloads", "RESTRICTED_noheliadasilva_4_25_2025_8_33_58.csv")

# Read CSV
HCP_unrestricted <- read.csv(HCP_unrestricted_fname)

# All subject IDS
subject_ids <- HCP_unrestricted$Subject

# Constants
fd_lag_HCP <- 4 
fd_cutoff <- .5 # Motion scrubbing threshold
TR_HCP <- .72 # Repetition time 
nT_HCP <- 1200 # Timepoints for each resting state scan
min_total_sec <- 600 # Minimum duration of time series after scrubbing (600 sec = 10 min)

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


