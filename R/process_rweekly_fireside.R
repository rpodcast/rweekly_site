library(jsonlite)
example_json <- "/workspaces/rweeky_site/fireside_rweekly_files/content/show/rweekly-highlights/0125.json"

# process json files of metadata
x <- fromJSON(example_json)

# using yaml package to convert to yaml fields

yaml::as.yaml(x)

yaml::write_yaml(x, file = "/workspaces/rweeky_site/R/test_yaml.yaml")

# using ymlthis package to create yml object
library(ymlthis)

post_yaml <- as_yml(x)


# process html show notes and convert to markdown
library(rmarkdown)

example_html <- "/workspaces/rweeky_site/fireside_rweekly_files/content/show/rweekly-highlights/0125_notes.html"

pandoc_convert(
  example_html, 
  to = "markdown_strict"
)