bucketed_df <-
    coverage_env$save_list$bucketed_df %>%
    filter(num_draws <= 64) %>%
    mutate(model=model_grouping)

num_draws <- unique(bucketed_df$num_draws)
draw_labels <- sprintf("%d draws", num_draws)
names(draw_labels) <- num_draws
model_labels <- GetModelLabels()

bucketed_df %>%
    mutate(p_bucket_num=as.numeric(p_bucket)) %>%
    mutate(p_bucket_num=p_bucket_num / max(p_bucket_num)) %>%
    ggplot() +
        geom_hline(aes(yintercept=1), alpha=0.6) +
        geom_line(aes(x=p_bucket_num, y=n_bins * p_dens,
                      group=model_grouping, color=model_grouping)) +
        facet_grid(model_grouping ~ num_draws,
                   labeller=labeller(num_draws=draw_labels,
                                     model_grouping=model_labels$labels),
                   scales="free") +
        expand_limits(y=0) +
        # scale_x_continuous(limits = c(0, 1),
        #                    minor_breaks = seq(0, 1, 10)) +
        # theme(axis.text.x=element_blank()) +
        GetModelScale(color=TRUE) +
        ylab("Proportion of p-values in bucket times # of buckets") +
        xlab("P-value bucket")
