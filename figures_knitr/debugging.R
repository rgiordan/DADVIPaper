# Use this script to debug and edit the knit graphs without re-compiling in latex.

base_dir <- "/home/rgiordan/Documents/git_repos/DADVI/fd-advi-paper/jmlr"

paper_directory <- file.path(base_dir)

knitr_debug <- FALSE # Set to true to see error output
example_cache <- FALSE

setwd(paper_directory)
source(file.path(paper_directory, "figures_knitr/initialize.R"))
source(file.path(paper_directory, "figures_knitr/load_data.R"))
source(file.path(paper_directory, "figures_knitr/define_macros.R"))
source(file.path(paper_directory, "figures_knitr/initialize.R"))

source("figures_knitr/traces_arm.R", echo=knitr_debug, print.eval=TRUE)
