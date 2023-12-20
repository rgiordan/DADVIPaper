
# Some plotting and table helper functions
GetRenameRow <- function(col, label) {
  data.frame(col=col, label=label)
}

# A convenient function for extracting only the legend from a ggplot.
# Taken from
# https://tinyurl.com/y8c742p6
GetLegend <- function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}


# Define common colors.
GGColorHue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}


GetModelLabels <- function() {
    model_breaks <- c("microcredit", "occ_det", "tennis", "potus", "ARM")
    model_labels <- c(
        "Microcredit",
        "Occupancy",
        "Tennis",
        "POTUS",
        "ARM")
    names(model_labels) <- model_breaks
    return(list(breaks=model_breaks, labels=model_labels))
}


GetModelScale <- function(color=FALSE) {
  model_labels <- GetModelLabels()

  if (color) {
    model_colors <- GGColorHue(length(model_labels$breaks))
    model_color_scale <-
        scale_color_manual(
            name="Model",
            values=model_colors,
            labels=model_labels$labels,
            aesthetics="color",
            drop=TRUE,
            limits = force)
    return(model_color_scale)
  } else {
    model_shapes <- 1:length(model_labels$breaks)
    names(model_shapes) <- model_labels$breaks

    model_shape_scale <-
        scale_shape_manual(
            name="Model",
            values=model_shapes,
            labels=model_labels$labels,
            # aesthetics="shape",
            drop=TRUE,
            limits=force)
    return(model_shape_scale)
  }
}


GetMethodLabels <- function() {
  method_breaks <- c(
    "NUTS", "RAABBVI", "SADVI", "SADVI_FR", "DADVI")
  method_labels <- c(
    "NUTS (MCMC)",
    "RAABBVI",
    "Mean field ADVI",
    "Full rank ADVI",
    "DADVI")
  names(method_labels) <- method_breaks
  return(list(breaks=method_breaks, labels=method_labels))
}


# Consistent colors and labels for stochastic methods
GetMethodScale <- function(fill=FALSE) {
  # all_env$metadata_df$method %>% unique()
  methods <- GetMethodLabels()
  method_breaks <- methods$breaks
  method_labels <- methods$labels
  method_colors <- GGColorHue(length(method_breaks))
  names(method_colors) <- method_breaks

  if (fill) {
    method_fill_scale <-
        scale_fill_manual(
            name="Inference method",
            values=method_colors,
            labels=method_labels,
            aesthetics = "fill",
            drop=TRUE,
            limits = force)
    return(method_fill_scale)
  } else {
    method_color_scale <-
        scale_color_manual(
            name="Method",
            values=method_colors,
            labels=method_labels,
            aesthetics = "color",
            drop=TRUE,
            limits = force)
    return(method_color_scale)
  }
}



# Get a legend (which can be passed to grid.arrange) for a particular
# set of methods.  Using this you can plot the legend only once for
# an array of plots.
GetColorLegend <- function(methods, fill=FALSE,
                           include_models=FALSE, models=c()) {
    if (fill) {
        plt <- data.frame(method=methods) %>%
            mutate(x=1) %>%
            ggplot() +
            geom_histogram(aes(x=x, fill=method), bins=2) +
            GetMethodScale(fill=TRUE)
    } else {
        plt <- data.frame(method=methods) %>%
            mutate(x=1) %>%
            ggplot() +
            geom_point(aes(x=x, y=x, color=method)) +
            GetMethodScale()
    }

    if (include_models) {
      # Include a shape scale for the models.
      stopifnot(length(models) > 0)
      model_labels <- GetModelLabels()
      model_shape_scale <- GetModelScale(color=FALSE)

      shape_df <- data.frame(model=models, x=1)
      plt <- plt +
          geom_point(aes(x=x, y=x, shape=model), data=shape_df) +
          model_shape_scale
    }
    return(GetLegend(plt))
}




# Plot the optimization traces
PlotTraces <- function(df) {
  SignedLog10 <- function(x) {
      case_when(x == 0 ~ 0,
                TRUE ~ sign(x) * log10(abs(x)))
  }

  SignedLog10Transform <- scales::trans_new(
      "signed_log10",
      SignedLog10,
      function(x) { sign(x) * 10^(abs(x)) }
      # breaks=function(b) { 10^round(SignedLog10(b)) },
      # minor_breaks=function(b, limits, n) { c() }
  )

  RightLog10 <- function(x) {
      case_when(x < 1 ~ x,
                TRUE ~ log10(x) + 1)
  }
  RightExp10 <- function(x) {
      case_when(x < 1 ~ x,
                TRUE ~ 10^(x - 1))
  }

  RightLog10Transform <- scales::trans_new(
      "right_log10",
      RightLog10, RightExp10
  )

  trace_norm_termination_df <-
      df %>%
        group_by(model, method) %>%
        filter(n_calls == max(n_calls))

    break_steps <- 10 ^ seq(0, 14, 2)
    breaks <- sort(c(-break_steps, break_steps))
    ggplot(df) +
        geom_line(aes(x=n_calls_norm, y=obj_value_norm,
                      color=method, group=paste0(method, model))) +
        geom_point(aes(x=n_calls_norm, y=obj_value_norm,
                       group=paste0(method, model)),
                       data=trace_norm_termination_df) +
        scale_y_continuous(trans=SignedLog10Transform, breaks=breaks) +
        scale_x_continuous(trans=RightLog10Transform) +
        geom_hline(aes(yintercept=0)) +
        geom_vline(aes(xintercept=1)) +
        xlab(TeX(paste0(
          "Normalized number of model evaluations ",
          "$i_{METHOD} / i^{*}_{DADVI}$ \n",
          "\n(Values > 1 are log10 transformed)"))) +
        ylab(TeX(paste0(
          "Normalized ELBO $\\kappa_{METHOD}^n$ ",
          "\n(signed log10 transformed)"))) +
        # ylab(paste0("(ELBO - DADVI optimal ELBO) / DADVI optimal ",
        #             "ELBO standard deviation\n",
        #             "(signed log10 transformed)")) +
        GetMethodScale(fill=FALSE)
}







# Posterior comparisons
PlotPostComparison <- function(comp_df, col1, col2,
                               model_label=FALSE, same_lims=TRUE,
                               plot_dens=TRUE) {
    lims <- max(pull(comp_df, {{col1}}), pull(comp_df, {{col2}}))

    # Label by the second method comparison
    comp_df$method <- comp_df$method_2

    if (model_label) {
        plt <-
            comp_df %>%
            ggplot(aes(x={{col1}}, y={{col2}})) +
            geom_point(aes(color=method, shape=model), size=4) +
            GetMethodScale() +
            GetModelScale(color=FALSE) +
            theme(legend.position="none")
    } else {
        plt <-
            comp_df %>%
            ggplot(aes(x={{col1}}, y={{col2}})) +
            geom_point(aes(color=method)) +
            GetMethodScale() +
            theme(legend.position="none")
    }

    plt <- plt +
        geom_abline(aes(slope=1, intercept=0)) +
        facet_grid(method_2 ~ ., scales="fixed") +
        theme(strip.background = element_blank(),
              strip.text.y = element_blank()) +
        scale_x_log10(labels=label_number()) +
        scale_y_log10(labels=label_number())

    if (plot_dens) {
        plt <- plt + geom_density2d(size=1, color="black", alpha=0.3)
    }

    if (same_lims) {
        plt <- plt + expand_limits(x=lims, y=lims)
    }
    return(plt)
}
