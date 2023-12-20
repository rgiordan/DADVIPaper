# Initialize R for knitr.

library(tidyverse)
library(knitr)
library(xtable)
library(gridExtra)
library(latex2exp)
#library(zaminfluence)
#library(stargazer)
library(scales)

# This must be run from within the git repo, obviously.
git_repo_loc <- system("git rev-parse --show-toplevel", intern=TRUE)
paper_directory <- file.path(git_repo_loc, "jmlr")
data_path <- file.path(paper_directory, "experiments_data")

# Plotting and processing functions common to multiple figures
source("figures_knitr/common_lib.R", echo=knitr_debug)

# Set some figure defaults.
opts_chunk$set(fig.pos='!h', fig.align='center', dev='png', dpi=300)

# Turn on verbose knitr if knitr_debug is TRUE
opts_chunk$set(echo=knitr_debug, message=knitr_debug, warning=knitr_debug)

# Set the default ggplot theme.
theme_set(theme_bw())

# A funciton to load data into an environment rather than the global space.
LoadIntoEnvironment <- function(filename) {
  my_env <- environment()
  load(filename, envir=my_env)
  return(my_env)
}

# Width in rendered units.  High numbers give smaller fonts on the images.
# Setting base_image_width to the actual width of a page of paper (8.5)
# lets ggplot pick what it thinks is best.
base_aspect_ratio <- 4 / 6
base_image_width <- 8.5

SetImageSize <- function(aspect_ratio=base_aspect_ratio,
                         image_width=base_image_width) {
  # Set the size on the page
  ow <- "0.98\\linewidth"
  oh <- sprintf("%0.3f\\linewidth", aspect_ratio * 0.98)

  # Set the size in rendering
  fw <- image_width
  fh <- image_width * aspect_ratio

  opts_chunk$set(out.width=ow,
                 out.height=oh,
                 fig.width=fw,
                 fig.height=fh)
}


SetFullImageSize <- function() SetImageSize(
    aspect_ratio=base_aspect_ratio, image_width=base_image_width)

# Default to a full image.
SetFullImageSize()
