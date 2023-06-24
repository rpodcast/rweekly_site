library(jsonlite)
example_json <- "/workspaces/rweekly_site/fireside_rweekly_files/content/show/rweekly-highlights/0125.json"

# process json files of metadata
x <- fromJSON(example_json)

# using yaml package to convert to yaml fields

yaml::as.yaml(x)

yaml::write_yaml(x, file = "/workspaces/rweekly_site/R/test_yaml.yaml")

# using ymlthis package to create yml object
library(ymlthis)

post_yaml <- as_yml(x)
use_yml_file(post_yaml, "/workspaces/rweekly_site/R/test2_yaml.yaml")

# process html show notes and convert to markdown
library(rmarkdown)

example_html <- "/workspaces/rweekly_site/fireside_rweekly_files/content/show/rweekly-highlights/0125_notes.html"

pandoc_convert(
  example_html, 
  to = "markdown_strict",
  output = "/workspaces/rweekly_site/R/episode_show_notes.md"
)

withr::with_tempfile("tf", {
  pandoc_convert(
    example_html, 
    to = "markdown_strict",
    output = tf
  )
  use_rmarkdown(post_yaml, "/workspaces/rweekly_site/R/test3_yaml.md", body = readLines(tf), overwrite = TRUE)
})


use_rmarkdown(post_yaml, "/workspaces/rweekly_site/R/test3_yaml.md", include_body = FALSE, overwrite = TRUE)