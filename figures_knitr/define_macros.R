# You can optinally use DefineMacro here to set latex macros to use R quantities
# in the text.

# Define LaTeX macros that will let us automatically refer
# to simulation and model parameters.
DefineMacro <- function(macro_name, value, digits=3) {
  #sprintf_code <- paste("%0.", digits, "f", sep="")
  value_string <- format(value, big.mark=",", digits=digits, scientific=FALSE)
  cat("\\newcommand{\\", macro_name, "}{", value_string, "}\n", sep="")
}


# Extract information about the models we fit
metadata_df <- all_env$metadata_df
num_arm_models <-
    filter(metadata_df, is_arm, method == "NUTS") %>%
      pull(model) %>%
      unique() %>%
      length()
DefineMacro("ARMNumModels", num_arm_models, digits=0)


# Get the parameter dimensions for the models
model_dim_df <-
    all_env$metadata_df %>%
    filter(method == "DADVI") %>%
    select(model, dim, is_arm) %>%
    unique()

arm_dims <-
    filter(model_dim_df, is_arm) %>%
    summarize(min=min(dim),
              med=median(dim),
              max=max(dim))

DefineMacro("MCParamDim",
  filter(model_dim_df, model == "microcredit")$dim,
  digits=0)
DefineMacro("OccParamDim",
  filter(model_dim_df, model == "occ_det")$dim,
  digits=0)
DefineMacro("PotusParamDim",
  filter(model_dim_df, model == "potus")$dim,
  digits=0)
DefineMacro("TennisParamDim",
  filter(model_dim_df, model == "tennis")$dim,
  digits=0)
DefineMacro("ARMMinParamDim", arm_dims$min, digits=0)
DefineMacro("ARMMedParamDim", arm_dims$med, digits=0)
DefineMacro("ARMMaxParamDim", arm_dims$max, digits=0)



# Get the runtimes for the models
runtime_df <-
    all_env$metadata_df %>%
    filter(method == "NUTS") %>%
    select(model, is_arm, runtime)

DefineMacro("TennisNUTSMinutes",
  filter(runtime_df, model=="tennis")$runtime / 60,
  digits=0)
DefineMacro("PotusNUTSMinutes",
  filter(runtime_df, model=="potus")$runtime / 60,
  digits=0)
DefineMacro("MCNUTSMinutes",
  filter(runtime_df, model=="microcredit")$runtime / 60,
  digits=0)
DefineMacro("OccNUTSMinutes",
  filter(runtime_df, model=="occ_det")$runtime / 60,
  digits=0)

arm_runtimes <-
  runtime_df %>%
    filter(is_arm) %>%
    summarize(min=min(runtime), med=median(runtime), max=max(runtime))
DefineMacro("ARMMinNUTSSeconds", arm_runtimes$min, digits=2)
DefineMacro("ARMMedNUTSSeconds", arm_runtimes$med, digits=2)
DefineMacro("ARMMaxNUTSMinutes", arm_runtimes$max / 60, digits=0)


num_draws_dadvi <-
  all_env$metadata_df %>%
  filter(method == "DADVI") %>%
  pull(num_draws_dadvi)

stopifnot(length(unique(num_draws_dadvi)) == 1)


# TODO: save this in the metadata?
DefineMacro("DADVINumDraws", unique(num_draws_dadvi), digits=0)


bucketed_df <- coverage_env$save_list$bucketed_df
n_bins <-
    bucketed_df %>%
    filter(model_grouping != "potus") %>%
    pull(p_bucket) %>% unique() %>% length()

n_bins_potus <-
    bucketed_df %>%
    filter(model_grouping == "potus") %>%
    pull(p_bucket) %>% unique() %>% length()
DefineMacro("CoverageNumBins", n_bins, digits=0)
DefineMacro("CoverageNumBinsPotus", n_bins_potus, digits=0)


arm_models <-
  all_env$metadata_df %>%
    filter(is_arm) %>%
    select(model, dim) %>%
    unique() %>%
    arrange(dim) %>%
    mutate(model=gsub("_", "\\\\_", model)) %>%
    mutate(model_dim=sprintf("%s (%d)", model, dim)) %>%
    pull(model_dim) %>%
    paste(collapse=", ")

DefineMacro("ArmModels", arm_models, digits=0)


# Count how many CG parameters we use
cg_count_df <-
  all_env$posteriors_df %>%
    filter(method == "LRVB_CG") %>%
    group_by(model) %>%
    summarize(n=n())
DefineMacro("TennisNumCGParams",
  filter(cg_count_df, model == "tennis")$n, digits=0)
DefineMacro("OccNumCGParams",
  filter(cg_count_df, model == "occ_det")$n, digits=0)
