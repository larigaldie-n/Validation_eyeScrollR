# Written by Nathanael Larigaldie

library(tidyverse)
library(png)
library(eyeScrollR)

source("R/data_merging_EyeLink.R")
source("R/eyeScrollR_correct_iMotions.R")
source("R/random_pick_fixation.R")

# Creates complete data files with eyeScrollR's correction for data sets from
# Imotions, and infers on which video frame each data point should be
eyeScrollR_correct_iMotions()

# Same thing for data sets from EyeLink, although it first merges data from
# Fixation & Gaze files, and synchronizes those with the videos
data_merging_EyeLink()

# Randomly picks 30 fixations per software, screen size & website. Fixations
# must last for at least 2 frames from a 24fps video (iMotions' format)
random_pick_fixation()
