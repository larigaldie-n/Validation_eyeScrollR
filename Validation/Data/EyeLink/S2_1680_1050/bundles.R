### Bundle 1
# Fixed area 1
bundle_1_fixed_area_1_screen <- c(0, 71, 1679, 258)
bundle_1_fixed_area_1_image <- c(0, 0, 1679, 187)
# Fixed area 2
bundle_1_fixed_area_2_screen <- c(1428, 259, 1679, 899)
bundle_1_fixed_area_2_image <- c(1428, 188, 1679, 828)
# Fixed area 3
bundle_1_fixed_area_3_screen <- c(1428, 900, 1679, 1009)
bundle_1_fixed_area_3_image <- c(1428, 3492, 1679, 3601)

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
bundle_2_fixed_area_1_screen <- c(0, 71, 1679, 165)
bundle_2_fixed_area_1_image <- c(0, 0, 1679, 94)
# Fixed area 2
bundle_2_fixed_area_2_screen <- c(1428, 166, 1679, 900)
bundle_2_fixed_area_2_image <- c(1428, 188, 1679, 922)
# Fixed area 3
bundle_2_fixed_area_3_screen <- c(1428, 900, 1679, 1009)
bundle_2_fixed_area_3_image <- c(1428, 3492, 1679, 3601)

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

save(fixed_areas, rules, file = file.path("Data", "EyeLink", "S2_1680_1050.RData"))