methods <- GetMethodLabels()
trace_norm_df <- trace_env$trace_norm_df
PlotTraces(trace_norm_df %>% filter(!is_arm)) +
    ggtitle("Standardized optimization traces for non-ARM") +
    facet_grid(method ~ ., labeller=labeller(method=methods$labels))
