# Written by Nathanael Larigaldie

get_sync_time <- function(file_name)
{
  d <- read_tsv(file.path("Data", "EyeLink", file_name, "Reports", "Output", "messages.xls"), col_types = "ccccc")
  d <- d %>% filter(CURRENT_MSG_TEXT == "SYNCTIME")
  return(as.numeric(d$CURRENT_MSG_TIME) + as.numeric(d$TRIAL_START_TIME))
}

merge_datasets <- function(file, sync_time, file_name)
{
  display_data <- read_csv(file.path("Data", "EyeLink", file)) %>% mutate(Timestamp = round(Timestamp)) %>% select(Timestamp, Source, Data)
  sync_time_display <- display_data$Timestamp[which(grepl("SYNCTIME", display_data$Data, fixed=TRUE))]
  sync_time_shift <- sync_time - sync_time_display
  gaze_data <- read_tsv(file.path("Data", "EyeLink", file_name, "Reports", "Output", "gaze.xls"), col_types = "ccccccc")
  fix_data <- read_tsv(file.path("Data", "EyeLink", file_name, "Reports", "Output", "fixations.xls"), col_types = "cccccccc")
  trial_start_time <- as.numeric(sub(",", ".", gaze_data$TRIAL_START_TIME[1], fixed = TRUE))
  merged_data <- gaze_data %>% left_join(fix_data %>% select(CURRENT_FIX_X, CURRENT_FIX_Y, CURRENT_FIX_START, CURRENT_FIX_END, CURRENT_FIX_INDEX), by=join_by(RIGHT_FIX_INDEX == CURRENT_FIX_INDEX))
  
  eyes_data <- tibble(Timestamp = as.numeric(sub(",", ".", merged_data$TIMESTAMP, fixed = TRUE)) - sync_time_shift,
                      Gaze.X = as.numeric(sub(",", ".", merged_data$RIGHT_GAZE_X, fixed = TRUE)),
                      Gaze.Y = as.numeric(sub(",", ".", merged_data$RIGHT_GAZE_Y, fixed = TRUE)),
                      Fixation.X = as.numeric(sub(",", ".", merged_data$CURRENT_FIX_X, fixed = TRUE)),
                      Fixation.Y = as.numeric(sub(",", ".", merged_data$CURRENT_FIX_Y, fixed = TRUE)),
                      Fixation.Start = as.numeric(sub(",", ".", merged_data$CURRENT_FIX_START, fixed = TRUE)) + trial_start_time - sync_time_shift,
                      Fixation.End = as.numeric(sub(",", ".", merged_data$CURRENT_FIX_END, fixed = TRUE)) + trial_start_time - sync_time_shift,
                      Fixation.Index = as.numeric(sub(",", ".", merged_data$RIGHT_FIX_INDEX, fixed = TRUE)))
  return(display_data %>% full_join(eyes_data, by="Timestamp") %>% arrange(Timestamp))
}

infer_video_frames_EyeLink <- function(d, fps)
{
  frame_number <- -1
  minutes <- 0
  seconds <- 0
  frame <- -1
  d$Video.Frame <- " "
  d$Video.Frame.N <- -1
  for(i in seq_len(nrow(d)))
  {
    if(grepl("Frame", d[[i, "Data"]], fixed=TRUE))
    {
      frame_number <- as.numeric(strsplit(d[[i, "Data"]], " ")[[1]][2])
      frame <- frame_number %% fps
      seconds <- floor(frame_number/fps) %% 60
      minutes <- floor(floor(frame_number/fps)/60) %% 60
    }
    d[i, "Video.Frame"] <- paste0(minutes, "m", seconds, "s", frame, "f")
    d[i, "Video.Frame.N"] <- frame_number
  }
  return(d)
}

data_merging_EyeLink <- function()
{
  fps <- 30.0
  
  list_files <- list.files(path= file.path("Data", "EyeLink"),pattern = "*.csv$")
  for(file in list_files)
  {
    file_name <- strsplit(file, ".", fixed=TRUE)[[1]][1]
    sync_time <- get_sync_time(file_name)
    d <- merge_datasets(file, sync_time, file_name)
    d <- infer_video_frames_EyeLink(d, fps)
    
    start_time <- d %>% filter(Data == "SYNCTIME")
    start_time <- start_time$Timestamp
    end_time <- d %>% filter(Data == "Key: 's' (Released)")
    end_time <- end_time$Timestamp
    
    # write_csv(d, file.path("Results", paste0(file_name, "_merged", ".csv")), na="")
    
    ## eyeScrollR specific code here
    
    # There was a very small modification on the browser layout in 2 study settings
    if(grepl("S1_1680_1050", file_name, fixed=TRUE) | grepl("S1_1920_1200", file_name, fixed=TRUE))
    {
      cal_img <- readPNG(file.path("Data", "EyeLink", paste0("calibration_", strsplit(file_name, "_", fixed=TRUE)[[1]][2], "_", strsplit(file_name, "_", fixed=TRUE)[[1]][3], "_S1", ".png")))
    }
    else
    {
      cal_img <- readPNG(file.path("Data", "EyeLink", paste0("calibration_", strsplit(file_name, "_", fixed=TRUE)[[1]][2], "_", strsplit(file_name, "_", fixed=TRUE)[[1]][3], ".png")))
    }
    cal <- scroll_calibration_auto(cal_img, 100)
    full_page_image <- readPNG(file.path("Data", "EyeLink", file_name, "full_page_image.png"))
    if(file.exists(file.path("Data", "EyeLink", paste0(file_name, ".RData"))))
    {
      load(file.path("Data", "EyeLink", paste0(file_name, ".RData")))
    }
    else
    {
      fixed_areas = list()
      rules = list()
    }
    img_wdth <- dim(full_page_image)[2]
    img_hgth <- dim(full_page_image)[1]
    if(grepl("S3", file, fixed=TRUE))
    {
      img_hgth <- img_hgth - 50
    }
    eye_scroll_correct(eyes_data = d, timestamp_start = start_time, timestamp_stop = end_time, image_width = img_wdth, image_height = img_hgth, calibration = cal, output_file = file.path("Results", paste0(file_name, ".csv")), scroll_lag = 1000/120, fixed_areas = fixed_areas, rules = rules)
  }
}

