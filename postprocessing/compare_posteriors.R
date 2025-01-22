library(gridExtra)
library(tidyverse)
library(shiny)

args <- commandArgs(trailingOnly = TRUE)

paper_base_folder <- args[1]

setwd(file.path(paper_base_folder, "postprocessing"))
source(file.path(paper_base_folder, "postprocessing/load_tidy_lib.R"))

output_folder <- file.path(paper_base_folder, "experiments_data")

models_to_remove <- GetModelsToRemove()
non_arm_models <- GetNonARMModels()

load(file.path(output_folder, "cleaned_experimental_results.Rdata"))


########################################
# Posteriors compared to a reference method

reference_method <- "NUTS"
stopifnot(sum(posteriors_df$method == reference_method) > 0)

# Note that we only have CG results for the match_predictions and presence_prediction.
any(is.na(posteriors_df$is_unconstrained))
results_all_df <-
    inner_join(posteriors_df %>% filter(method != reference_method),
               posteriors_df %>% filter(method == reference_method),
               by=c("model", "param", "ind", "is_arm", "is_unconstrained"),
               suffix=c("", "_ref")) %>%
    mutate(param=case_when(
        (model == "tennis") & (param == "match_predictions") ~ paste(param, ind, sep="_"),
        (model == "occ_det") & (param == "presence_prediction") ~ paste(param, ind, sep="_"),
        TRUE ~ param
    )) %>% # For certain parameters, treat each index as a "parameter" for purposes of reporting accuracy
    mutate(mean_z_err=(mean - mean_ref) / sd_ref,
           sd_rel_err=(sd - sd_ref) / sd_ref) %>%
    mutate(is_arm=IsARM(model),
           param_ind=paste0(param, ind)) # This makes it easier to count distinct parameters
    # filter(report_param) %>%
    # filter(is_unconstrained) # Can't only report unconstrained and also have the LRVB_CG results

# Use LRVB_CG or LRVB as the "LR" method according to lrvb_methods_df
lr_methods <- c("LRVB", "LRVB_CG")
results_lr_df <-
    results_all_df %>%
    filter(method %in% lr_methods) %>%
    inner_join(lrvb_methods_df, by=c("model", "method")) %>%
    mutate(old_method=method) %>%
    mutate(method="LR")

results_df <-
    bind_rows(results_lr_df,
              filter(results_all_df, !(method %in% lr_methods)))

# Sanity check for bad reference values
filter(results_df, sd_ref < 1e-6) %>%
    select(method, model, param, ind, mean, sd, mean_ref, sd_ref)

# # Everything needs an LR method
# filter(results_df, method == "LR") %>% filter(!is_arm) %>% pull(model) %>% unique()
# 
# filter(posteriors_df) %>% filter(!is_arm) %>% select(model, method) %>% unique() %>% filter(method %in% lr_methods)
# filter(results_df) %>% filter(!is_arm) %>% select(model, method) %>% unique()
# 
# filter(lrvb_methods_df, model %in% non_arm_models) %>%  select(model, method) %>% unique()
# filter(posteriors_df, model %in% non_arm_models) %>%  select(model, method) %>% unique() %>% filter(method %in% lr_methods)
# filter(results_lr_df, model %in% non_arm_models) %>%  select(model, method) %>% unique()
# filter(results_all_df, model %in% non_arm_models) %>%  select(model, method) %>% unique() %>% filter(method %in% lr_methods)

########################################
# Aggregate and compare posterior results

# Compute aggregated errors between two methods
GetMethodComparisonDf <- function(results_df, method1, method2, group_cols) {
    # group_cols should be a string vector (for inner_join)

    stopifnot(method1 %in% unique(results_df$method))
    stopifnot(method2 %in% unique(results_df$method))

    # Note that we remove zero sd_ref here, but we should not assume
    # that a datapoint is bad just because sd_ref is zero.
    # Rather, we should make sure above that we're not
    # accidentally hiding real mistakes.
    agg_results_df <-
        results_df %>%
        filter(sd_ref > 1e-6) %>%
        group_by(across({{group_cols}}), method) %>%
        summarise(mean_z_rmse=sqrt(mean(mean_z_err^2)),
                  sd_rel_rmse=sqrt(mean(sd_rel_err^2)),
                  .groups="drop")
    stopifnot(!any(c(
        any(is.na(agg_results_df$mean_z_rmse)),
        any(is.na(agg_results_df$sd_rel_rmse))
    )))

    comp_df <-
        inner_join(filter(agg_results_df, method == !!method1),
                   filter(agg_results_df, method == !!method2),
                   suffix=c("_1", "_2"),
                   by=group_cols) %>%
        mutate(comparison=paste0(method1, " vs ", method2))
    return(comp_df)
}



# Call GetMethodComparisonDf for multiple methods and rbind the dataframes.
GetMethodComparisonsDf <- function(results_df, dadvi_methods, comp_methods, group_cols) {
    result_list <- list()
    for (dadvi_method in dadvi_methods) {
        for (comp_method in comp_methods) {
            result_list[[length(result_list) + 1]] <-
                GetMethodComparisonDf(
                    results_df, dadvi_method, comp_method, group_cols=all_of(group_cols))
        }
    }
    do.call(bind_rows, result_list)
}    


posterior_comp_df <- results_df %>%
    GetMethodComparisonsDf(c("DADVI", "LR"), 
                           c("SADVI", "RAABBVI", "SADVI_FR"), 
                           c("model", "param", "is_arm"))



save(posterior_comp_df, file=file.path(output_folder, "posteriors.Rdata"))




