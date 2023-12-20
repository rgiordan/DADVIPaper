# Make it easy to change row and column names later
table_cols <- bind_rows(
    GetRenameRow("x_mean", "Mean of Regressor"),
    GetRenameRow("y_mean", "Mean of Response"),
    GetRenameRow("y_var", "Variance of Response"),
)

table_headers <-
    c("x_mean"="Mean of Regressor",
      "y_mean"="Mean of Response",
      "y_var"="Variance of Response")

# Haven't used kable myself but it looks pretty good
# https://haozhu233.github.io/kableExtra/awesome_table_in_pdf.pdf
knitr::kable(example_env$summary_df,
             col.names=table_headers[names(example_env$summary_df)],
             format="latex",
             booktabs=TRUE,
             digits=3,
             label="example_table",
             caption="What is this even?")
