### Bundle 1
# Fixed area 1
bundle_1_fixed_area_1_screen <- c(0, 71, 1919, 120)
bundle_1_fixed_area_1_image <- c(0, 0, 1919, 49)

## Rule for bundle 1
rule_true <- function (data_line, fixed_areas_bundle, flag, scroll)
{
  return (TRUE)
}

areas_bundle_1 <- fixed_areas_bundle(bundle_1_fixed_area_1_screen, bundle_1_fixed_area_1_image)

fixed_areas <- list(areas_bundle_1)
rules <- list(rule_true)

save(fixed_areas, rules, file = file.path("Data", "EyeLink", "S4_1920_1200.RData"))