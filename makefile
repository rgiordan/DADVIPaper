# make --debug=verbose for info
# make -B to force
# make --dry-run


# Set these variables to the paths of the paper repo and experiments repos.

# The (present) repo for the actual paper.
PAPER_REPO := /media/martin/external_drive/DADVIPaper/
EXP_REPO := /media/martin/external_drive/dadvi-experiments/


######################################################
# Subdirectory variables for concise targets.

POSTERIORS_DIR := $(EXP_REPO)/comparison/experiment_runs/november_2024/models
COVERAGE_DIR := $(EXP_REPO)/comparison/experiment_runs/november_2024/coverage

ANALYSIS_DIR := $(EXP_REPO)/comparison/analysis

######################################################
# Experimental data.
# Three stages: Python -> R -> Knitr

POST_TIDY_CMD := 'In '$(ANALYSIS_DIR)', run `make PosteriorsLoadAndTidyAndSave`'
$(POSTERIORS_DIR)/posteriors_tidy.csv: 
	echo $(POST_TIDY_CMD)
$(POSTERIORS_DIR)/metadata_tidy.csv:
	echo $(POST_TIDY_CMD)
$(POSTERIORS_DIR)/trace_tidy.csv:
		echo $(POST_TIDY_CMD)
$(POSTERIORS_DIR)/params_tidy.csv:
	echo $(POST_TIDY_CMD)
$(POSTERIORS_DIR)/mcmc_diagnostics_tidy.csv:
	echo $(POST_TIDY_CMD)

# Experimental data in the format needed for the paper.
PAPERDATA_DIR := $(PAPER_REPO)/experiments_data
PP_DIR := $(PAPER_REPO)/postprocessing

# Process Python base runs
exp_data := $(PAPERDATA_DIR)/cleaned_experimental_results.Rdata
$(exp_data): \
		$(POSTERIORS_DIR)/posteriors_tidy.csv \
		$(POSTERIORS_DIR)/metadata_tidy.csv \
		$(POSTERIORS_DIR)/trace_tidy.csv \
		$(POSTERIORS_DIR)/params_tidy.csv \
		$(POSTERIORS_DIR)/mcmc_diagnostics_tidy.csv 
	Rscript $(PP_DIR)/load_tidy_results.R $(POSTERIORS_DIR) $(PAPER_REPO)
.PHONY: exp_data
exp_data: $(exp_data)


# Process Python reruns
COVERAGE_CMD := 'In '$(ANALYSIS_DIR)', run `make FrequentistCoverageLoadAndTidyAndSave`'
$(COVERAGE_DIR)/coverage_tidy.csv:
	echo $(COVERAGE_CMD)

cov_data := $(PAPERDATA_DIR)/coverage_summary.Rdata
$(cov_data): \
		$(COVERAGE_DIR)/coverage_tidy.csv
	Rscript $(PP_DIR)/load_tidy_coverage_results.R $(COVERAGE_DIR) $(PAPER_REPO)
.PHONY: cov_data
cov_data: $(cov_data)


# Further processing of the R output
post_data := $(PAPERDATA_DIR)/posteriors.Rdata
$(post_data): $(exp_data)
	Rscript $(PP_DIR)/compare_posteriors.R $(PAPER_REPO)
.PHONY: post_data
post_data: $(post_data)

runtime_data := $(PAPERDATA_DIR)/runtime.Rdata
$(runtime_data): $(exp_data)
	Rscript $(PP_DIR)/compare_runtime.R $(PAPER_REPO)
.PHONY: runtime_data
runtime_data: $(runtime_data)

trace_data := $(PAPERDATA_DIR)/traces.Rdata
$(trace_data): $(exp_data)
	Rscript $(PP_DIR)/compare_traces.R $(PAPER_REPO)
.PHONY: trace_data
trace_data: $(trace_data)


PP_DATA := $(exp_data) $(cov_data) $(post_data) $(runtime_data) $(trace_data)


###################################
# The actual paper.

.PHONY: all
all: main.pdf


TEX_FILES := $(wildcard *.tex)

main.pdf: figures_knitr.tex $(TEX_FILES)
	pdflatex main.tex
	pdflatex main.tex
	bibtex main
	pdflatex main.tex
	pdflatex main.tex


figures_knitr.tex: $(PP_DATA)
	Rscript -e 'library(knitr); knit("figures_knitr.Rnw")'


.PHONY: recompile_knitr
recompile_knitr:
	Rscript -e 'library(knitr); knit("figures_knitr.Rnw")'
	pdflatex main.tex


###################################
# Cleaning

.PHONY: postprocess_clean
postprocess_clean:
	for DATA in $(PP_DATA) ; do \
		rm -f $$DATA; \
	done


.PHONY: latex_clean
latex_clean:
	for latextext in aux bbl blg log out pdf thm ; do \
		rm -f main.$$latextext; \
	done

.PHONY: knitr_clean
knitr_clean:
	rm -f figures_knitr.tex
	rm -f figure/*
	rm -f cache/*

.PHONY: archive
archive:
	ls archive || mkdir archive
	cp *.tex archive/
	cp -R figure archive/
	cp references.bib archive/
	cp jmlr2e.sty archive/

.PHONY: archive_clean
archive_clean:
	rm -Rf archive/*


.PHONY: clean
clean: latex_clean knitr_clean
