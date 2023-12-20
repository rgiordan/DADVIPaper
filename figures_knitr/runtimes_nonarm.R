
runtime_comp_df <- runtime_env$runtime_comp_df

# Set a common scale for all the graphs
y_cols <- c("runtime_vs_dadvi", "runtime_vs_lrvb", 
            "op_count_vs_dadvi", "op_count_vs_lrvb")
runtime_comp_df <- runtime_env$runtime_comp_df
y_vals <-
  runtime_comp_df[, y_cols] %>% pivot_longer(cols=everything()) %>% pull(value)
y_range <- (c(min(y_vals, na.rm=TRUE), max(y_vals, na.rm=TRUE)))



# Plot the relative runtimes for the big models
ComputationComparisonBarGraph <- function(comp_df, col) {
    model_labels <- GetModelLabels()$labels
    comp_df <-
        comp_df %>%
        complete(method, model) %>%
        mutate(model_label=model_labels[model])
    plt <-
        comp_df %>%
        ggplot() +
            geom_bar(aes(x=model_label, group=model_label, fill=method,
                         y={{col}}), stat="Identity") +
            scale_y_log10(limits=c(y_range[1], y_range[2])) +
            theme(axis.text.x=element_text(angle = 90, vjust = 0.5, hjust=1),
                  strip.background = element_blank(),
                  strip.text.x = element_blank()) +
            facet_grid( ~ method) +
            geom_hline(aes(yintercept=1), color="black") +
            GetMethodScale(fill=TRUE) +
            xlab("Model") +
            theme(legend.position="none")
            

    missing_model_methods <-
        comp_df %>%
        filter(is.na(runtime))

    plt <-
        plt +
        geom_text(aes(x=model_label, y=1, group=model_label, label="x"),
                   size=5, vjust="center",
                   data=missing_model_methods)

    return(plt)
}



method_legend <- GetColorLegend(
    methods=runtime_comp_df$method %>% unique(), fill=TRUE)

plot_layout <- rbind(c(1,3,5),
                     c(2,4,5))

# Op count not meaningful for NUTS
grid.arrange(
    runtime_comp_df %>% filter(!is_arm) %>%
        ComputationComparisonBarGraph(runtime_vs_dadvi) +
        ggtitle("Runtime relative to DADVI") +
        ylab("Runtime / DADVI runtime\n(log10 scale)"),
    runtime_comp_df %>%
        filter(!is_arm, method != "NUTS") %>%
        ComputationComparisonBarGraph(op_count_vs_dadvi) +
        ggtitle("Evals relative to DADVI") +
        ylab("Model evals / DADVI model evals\n(log10 scale)"),
    runtime_comp_df %>% filter(!is_arm) %>%
        ComputationComparisonBarGraph(runtime_vs_lrvb) +
        ggtitle("Runtime relative to LRVB") +
        ylab("Runtime / LRVB runtime\n(log10 scale)"),
    runtime_comp_df %>% filter(!is_arm, method != "NUTS") %>%
        ComputationComparisonBarGraph(op_count_vs_lrvb) +
        ggtitle("Evals relative to LRVB") +
        ylab("Model evals / LRVB model evals\n(log10 scale)"),
    method_legend,
    layout_matrix=plot_layout)
