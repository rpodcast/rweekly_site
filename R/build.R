# An optional custom script to run before Hugo builds your site.
# You can delete it if you do not need it.
message("running in build.R")

# TODO: 
# - use a YAML to store overall podcast-related RSS parameters
# - import the config file with yaml::read_yaml("config.yaml:") and subset to grab only the parameters I need

#podcast_meta <- yaml::read_yaml("podcast.yaml")


# - use the yaml frontmatter of each episode markdown file to store episode-specific RSS parameters
# - list all episode files
# - import the yaml of all episodes using purrr
# - arrange order by descending order of date
# - 