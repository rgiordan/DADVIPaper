posterior_comp_df <- post_env$posterior_comp_df

legend <- GetColorLegend(unique(posterior_comp_df$method_2))
arm_mean_plot <-
    posterior_comp_df %>%
    filter(is_arm, method_1 == "DADVI") %>%
    PlotPostComparison(mean_z_rmse_1, mean_z_rmse_2) +
    xlab(TeX("DADVI relative error $\\epsilon_{DADVI}^{\\mu}$ (log10 scale)")) +
    ylab(TeX("Stochastic VI relative error $\\epsilon_{\\textrm{METHOD}}^{\\mu}$ (log10 scale)")) +
    ggtitle("Mean relative error\n(ARM models)")

arm_sd_plot <-
    posterior_comp_df %>%
    filter(is_arm, method_1 == "LR") %>%
    PlotPostComparison(sd_rel_rmse_1, sd_rel_rmse_2) +
    xlab(TeX("LRVB relative error $\\epsilon_{LRVB}^{\\sigma}$ (log10 scale)")) +
    ylab(TeX("Stochastic VI relative error $\\epsilon_{\\textrm{METHOD}}^{\\sigma}$ (log10 scale)")) +
    ggtitle("Standard deviation relative error\n(ARM models)")

grid.arrange(
    arm_mean_plot, arm_sd_plot, legend,
    ncol=3, widths=c(2,2,1)
)
