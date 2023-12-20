posterior_comp_df <- post_env$posterior_comp_df

legend <- GetColorLegend(
    unique(posterior_comp_df$method_2),
    include_models=TRUE,
    models=filter(posterior_comp_df, !is_arm) %>% pull(model) %>% unique())

nonarm_mean_plot <-
    posterior_comp_df %>%
    filter(!is_arm, method_1 == "DADVI") %>%
    PlotPostComparison(
      mean_z_rmse_1, mean_z_rmse_2, plot_dens=FALSE, model_label=TRUE) +
    xlab(TeX("DADVI relative error $\\epsilon_{DADVI}^{\\mu}$ (log10 scale)")) +
    ylab(TeX("Stochastic VI relative error $\\epsilon_{\\textrm{METHOD}}^{\\mu}$ (log10 scale)")) +
    ggtitle("Mean relative error\n(non-ARM models)")

nonarm_sd_plot <-
    posterior_comp_df %>%
    filter(!is_arm, method_1 == "LR") %>%
    PlotPostComparison(
      sd_rel_rmse_1, sd_rel_rmse_2, plot_dens=FALSE, model_label=TRUE) +
    xlab(TeX("LRVB relative error $\\epsilon_{LRVB}^{\\sigma}$ (log10 scale)")) +
    ylab(TeX("Stochastic VI relative error $\\epsilon_{\\textrm{METHOD}}^{\\sigma}$ (log10 scale)")) +
    ggtitle("Standard deviation relative error\n(non-ARM models)")

grid.arrange(
    nonarm_mean_plot, nonarm_sd_plot, legend,
    ncol=3, widths=c(2,2,1)
)
