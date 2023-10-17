### Bundle 1
# Fixed area 1
bundle_1_fixed_area_1_screen <- c(0, 71, 1919, 288)
bundle_1_fixed_area_1_image <- c(0, 0, 1919, 217)
# Fixed area 2
bundle_1_fixed_area_2_screen <- c(1632, 289, 1919, 1031)
bundle_1_fixed_area_2_image <- c(1632, 218, 1919, 960)
# Fixed area 3
bundle_1_fixed_area_3_screen <- c(1632, 1032, 1919, 1159)
bundle_1_fixed_area_3_image <- c(1632, 3566, 1919, 3693)

## Rule for bundle 1
rule_before_scrolling <- function (data_line, fixed_areas_bundle, flag, scroll)
{
  ### Change VALUE to fit your needs ###
  if (scroll < 1000)
  {
    return (TRUE)
  }
  else
  {
    return(FALSE)
  }
}

areas_bundle_1 <- fixed_areas_bundle(bundle_1_fixed_area_1_screen, bundle_1_fixed_area_1_image,
                                     bundle_1_fixed_area_2_screen, bundle_1_fixed_area_2_image,
                                     bundle_1_fixed_area_3_screen, bundle_1_fixed_area_3_image)

### Bundle 2
# Fixed area 1
bundle_2_fixed_area_1_screen <- c(0, 71, 1919, 180)
bundle_2_fixed_area_1_image <- c(0, 0, 1919, 109)
# Fixed area 2
bundle_2_fixed_area_2_screen <- c(1632, 181, 1919, 1031)
bundle_2_fixed_area_2_image <- c(1632, 218, 1919, 1068)
# Fixed area 3
bundle_2_fixed_area_3_screen <- c(1632, 1032, 1919, 1159)
bundle_2_fixed_area_3_image <- c(1632, 3566, 1919, 3693)

## Rule for bundle 2
rule_after_scrolling <- function (data_line, fixed_areas_bundle, flag, scroll)
{
  ### Change VALUE to fit your needs ###
  if (scroll >= 1000)
  {
    return (TRUE)
  }
  else
  {
    return(FALSE)
  }
}

areas_bundle_2 <- fixed_areas_bundle(bundle_2_fixed_area_1_screen, bundle_2_fixed_area_1_image,
                                     bundle_2_fixed_area_2_screen, bundle_2_fixed_area_2_image,
                                     bundle_2_fixed_area_3_screen, bundle_2_fixed_area_3_image)

fixed_areas <- list(areas_bundle_1, areas_bundle_2)
rules <- list(rule_before_scrolling, rule_after_scrolling)

save(fixed_areas, rules, file = file.path("Data", "EyeLink", "S2_1920_1200.RData"))