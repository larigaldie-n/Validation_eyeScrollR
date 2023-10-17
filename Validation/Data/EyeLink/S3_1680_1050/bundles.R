### Bundle 1
# Fixed area 1
bundle_1_fixed_area_1_screen <- c(0, 71, 1679, 136)
bundle_1_fixed_area_1_image <- c(0, 0, 1679, 65)
# Fixed area 2
bundle_1_fixed_area_2_screen <- c(1626, 178, 1679, 367)
bundle_1_fixed_area_2_image <- c(1626, 107, 1679, 296)
# Fixed area 3
bundle_1_fixed_area_3_screen <- c(0, 960, 1679, 1009)
bundle_1_fixed_area_3_image <- c(0, 4065, 1679, 4114)

## Rule for bundle 1
rule_true <- function (data_line, fixed_areas_bundle, flag, scroll)
{
  return (TRUE)
}

areas_bundle_1 <- fixed_areas_bundle(bundle_1_fixed_area_1_screen, bundle_1_fixed_area_1_image,
                                     bundle_1_fixed_area_2_screen, bundle_1_fixed_area_2_image,
                                     bundle_1_fixed_area_3_screen, bundle_1_fixed_area_3_image)

fixed_areas <- list(areas_bundle_1)
rules <- list(rule_true)

save(fixed_areas, rules, file = file.path("Data", "EyeLink", "S3_1680_1050.RData"))