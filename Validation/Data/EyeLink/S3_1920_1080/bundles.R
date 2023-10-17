### Bundle 1
# Fixed area 1
bundle_1_fixed_area_1_screen <- c(0, 71, 1919, 136)
bundle_1_fixed_area_1_image <- c(0, 0, 1919, 65)
# Fixed area 2
bundle_1_fixed_area_2_screen <- c(1866, 178, 1919, 367)
bundle_1_fixed_area_2_image <- c(1866, 107, 1919, 296)
# Fixed area 3
bundle_1_fixed_area_3_screen <- c(0, 990, 1919, 1039)
bundle_1_fixed_area_3_image <- c(0, 4065, 1919, 4114)

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

save(fixed_areas, rules, file = file.path("Data", "EyeLink", "S3_1920_1080.RData"))