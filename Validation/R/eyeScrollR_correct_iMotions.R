# Written by Nathanael Larigaldie

infer_video_frames <- function(d, fps, start)
{
  d <- d %>% mutate(Video.Frame.N = floor((Timestamp - start)*fps / (1000)))
  d <- d %>% mutate(Video.Frame = paste0(floor(floor(Video.Frame.N/fps)/60) %% 60, "m", floor(Video.Frame.N/fps) %% 60, "s", Video.Frame.N %% fps, "f"))
  d <- d %>% mutate(Video.Frame = ifelse(Video.Frame.N<0, paste0(0, "m", 0, "s", -1, "f"), Video.Frame))
  return(d)
}

eyeScrollR_correct_iMotions <- function()
{
  fps <- 24
  
  d <- read_csv(file.path("Data", "iMotions", "data.csv"), comment = "#")
  names(d) <- make.names(names(d))
  
  d <- d %>% select(Timestamp, SlideEvent, Data, Fixation.X, Fixation.Y)
  d_start_stop <- d %>% filter(grepl("MouseEvent:WM_LBUTTONDOWN", Data, fixed=TRUE) | grepl("Key:W", Data, fixed=TRUE))
  t_shift <- d %>% filter(SlideEvent == "StartMedia") %>% select(Timestamp)
  d <- infer_video_frames(d, fps, t_shift$Timestamp[1])
  
  
  cal_img <- readPNG(file.path("Data", "iMotions", "calibration_1920_1080.png"))
  cal <- scroll_calibration_auto(cal_img, 100)
  
  for(i in seq_len(4))
  {
    full_page_image <- readPNG(file.path("Data", "iMotions", paste0("S", i, "_1920_1080"), "full_page_image.png"))
    img_wdth <- dim(full_page_image)[2]
    img_hgth <- dim(full_page_image)[1]
    if(i==3)
    {
      img_hgth <- img_hgth - 50
    }
    if(file.exists(file.path("Data", "iMotions", paste0("S", i, "_1920_1080", ".RData"))))
    {
      load(file.path("Data", "iMotions", paste0("S", i, "_1920_1080", ".RData")))
    }
    else
    {
      fixed_areas = list()
      rules = list()
    }
    eye_scroll_correct(eyes_data = d, timestamp_start = d_start_stop$Timestamp[i], timestamp_stop = d_start_stop$Timestamp[i+1], image_width = img_wdth, image_height = img_hgth, calibration = cal, time_shift = t_shift$Timestamp[1], output_file = file.path("Results", paste0("S", i, "_1920_1080_iMotions", ".csv")), scroll_lag = (1/120)*1000, fixed_areas = fixed_areas, rules = rules)
  }
}