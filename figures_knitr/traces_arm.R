trace_norm_df <- trace_env$trace_norm_df
methods <- GetMethodLabels()
trace_norm_df %>%
  filter(is_arm) %>%
  PlotTraces() +
    ggtitle("Standardized optimization traces for ARM") +
    facet_grid(method ~ ., labeller=labeller(method=methods$labels))
