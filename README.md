# DADVIPaper

This repository contains code and text to reproduce our paper, 

> R. Giordano*, M. Ingram* & T. Broderick (2023). Black Box Variational Inference
with a Deterministic Objective: Faster, More Accurate, and Even More Black Box.
`*` = equal contribution first authors.
[arXiv:2304.05527](https://arxiv.org/abs/2304.05527)

To compile, edit the header of the `makefile` to point to this repositry as
well as the experiments repository (which is currently [martiningram/dadvi-experiments](https://github.com/martiningram/dadvi-experiments)).
Then run `make all`.

Note that you should be able to compile the paper using the postprocessed
experiments data included in this repo.  To re-run the experiments, see
[martiningram/dadvi-experiments](https://github.com/martiningram/dadvi-experiments).
Note that the experiments are time consuming and disk-intensive, and so are not
included in the present repository.


## Knitr setup

The knitr setup may seem a little complicated at first, but I like how
fast it is to recompile, and how modular it makes everything.

The short summary of how it is used for a particular experiment is:

1) The minimal amount of data needed to generate tables and figures
is saved in an Rdata file stored in `experiments_data`.

2) A line in `figures_knitr/load_data.R` to loads the experiment data
into an `R` environment.

3) To refer in the text to any key quantities from the experiment, we add
lines to `figures_knitr/define_macros.R`.

4) We add standalone `.R` files to `figures_knitr` to generate individual figures
and tables.  

5) We define macros in `figures_knitr.Rnw` that source your figure and
table files.  Don't edit `figures_knitr.tex`, that file is overwritten!

6) To compile `figures_knitr.Rnw` into `figures_knitr.tex`, run `make
figutes_knitr.tex`.  To force re-running knitr, run `make recompile_knitr`.  If
it fails, debug as in step (8).

7) Use the macros in the main latex text to place figures, tables, and numbers
where you want them.  Note that you can move the figures around and recompile
LaTeX with no additional knitting.

8) For debugging, it can be helpful to check the R output with
`debugging.R`, then the tex output by looking at (but not editing)
`figures_knitr.tex`.  If needed, you can also set `knitr_debug <- TRUE`
in `figures_knitr.Rnw` to see verbose R output in LaTeX after knitting.
