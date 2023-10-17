# Written by Nathanael Larigaldie

list_files <- list.files(path = "Results", pattern = "*.csv$")
for(file in list_files)
{
  d <- read_csv(file.path("Results", file))
  d <- d %>%
    filter(!is.na(Corrected.Fixation.Y)) %>%
    select(Timestamp.Shifted, Corrected.Fixation.X, Corrected.Fixation.Y, Fixation.X, Fixation.Y, Video.Frame.N, Video.Frame) %>%
    group_by(Corrected.Fixation.X, Corrected.Fixation.Y, Fixation.X, Fixation.Y) %>%
    summarise(Ts.Start = first(Timestamp.Shifted), Ts.End = last(Timestamp.Shifted), V.Frame.N = nth(Video.Frame.N, round(n()/2)), V.Frame = nth(Video.Frame, round(n()/2))) %>%
    ungroup() %>%
    filter(!is.na(V.Frame.N), (Ts.End - Ts.Start)>(2/24)*1000) %>%
    slice_sample(n=30) %>%
    arrange(Ts.Start)
  write_csv(d, file.path("Results", "Complete", file))
  write_csv(d %>% select(Fixation.X, Fixation.Y, V.Frame, V.Frame.N), file.path("Results", "Blinded", file))
}