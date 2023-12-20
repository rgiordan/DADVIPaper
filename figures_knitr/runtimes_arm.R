

# Plot the relative runtimes for the ARM models
ComputationComparisonHistogramGraph <- function(comp_df, col) {
    methods <- GetMethodLabels()
    plt <- ggplot(comp_df) +
        geom_histogram(aes(x={{col}}, fill=method), bins=30) +
        geom_vline(aes(xintercept=1)) +
        scale_x_log10() +
        expand_limits(x=1) +
        # facet_grid(method ~ ., labeller=labeller(method=methods$labels)) +
        facet_grid(method ~ .) +
        GetMethodScale(fill=TRUE) +
        theme(legend.position="none",
              strip.background = element_blank(),
              strip.text.y = element_blank())

    return(plt)
}

runtime_comp_df <- runtime_env$runtime_comp_df

method_legend <- GetColorLegend(
    methods=runtime_comp_df$method %>% unique(), fill=TRUE)

runtime_dadvi_plot <-
    runtime_comp_df %>% filter(is_arm) %>%
    ComputationComparisonHistogramGraph(runtime_vs_dadvi) +
    xlab("Runtime / DADVI runtime\n(log10 scale)")

# Op count not meaningful for NUTS
op_dadvi_plot <-
    runtime_comp_df %>%
      filter(is_arm, method != "NUTS") %>%
      ComputationComparisonHistogramGraph(op_count_vs_dadvi) +
        xlab("Model evals / DADVI model evals\n(log10 scale)")

runtime_lrvb_plot <-
    runtime_comp_df %>% filter(is_arm) %>%
    ComputationComparisonHistogramGraph(runtime_vs_lrvb) +
    xlab("Runtime / LRVB runtime\n(log10 scale)")

# Op count not meaningful for NUTS
op_lrvb_plot <-
    runtime_comp_df %>%
      filter(is_arm, method != "NUTS") %>%
      ComputationComparisonHistogramGraph(op_count_vs_lrvb) +
        xlab("Model evals / LRVB model evals\n(log10 scale)")

plot_layout <- rbind(c(1,3,5),
                     c(2,4,5))

grid.arrange(
    runtime_dadvi_plot,
    op_dadvi_plot,
    runtime_lrvb_plot,
    op_lrvb_plot,
    method_legend,
    layout_matrix=plot_layout)
