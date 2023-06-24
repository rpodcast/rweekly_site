#' Core functions for RSS Feed and blog processing
#' 
#' This script provides utility functions used during the
#' processing of web site episode files as well as 
#' generating the RSS feed of the podcast istelf
'.__module__'

#' parse publish date into separate components
#' @param publish_date string of publish date
#' @name core
#' @return list with invidual components
#' @export
parse_publish_date <- function(publish_date) {
  box::use(lubridate[...])

  # convert to date-time object
  x <- ymd_hms(publish_date)

  # extract individual components into a list
  x2 <- list(
    year = as.integer(year(x)),
    month = as.integer(month(x)),
    day = as.integer(mday(x)),
    hour = as.integer(hour(x)),
    minute = as.integer(minute(x)),
    second = as.integer(second(x))
  )

  return(x2)
}

#' import yaml metadata from episode file
#' @param file full path to episode markdown file
#' @name core
#' @return list of episode metadata from yaml header
#' @export
import_episode_metadata <- function(file) {
  box::use(rmarkdown[yaml_front_matter])

  x <- yaml_front_matter(file)
  return(x)
}

#' import podcast metadata from blogdown config file
#' @param file full path to blogdown config file
#' @name core
#' @return list of podcast metadata from config file
#' @export
import_podcast_metadata <- function(file) {
  box::use(yaml[read_yaml])

  x <- read_yaml(file)
  
  # parse out select elements for final list
  p_meta <- list(
    description = x$params$description,
    language = x$params$feed$language,
    title = x$title,
    website = x$baseurl,
    explicit = x$params$feed$explicit,
    copyright = x$params$feed$copyright,
    author = x$params$feed$itunes_author,
    category = x$params$feed$itunes_top_category,
    image = x$params$feed$itunes_image,
    feed_url = x$params$feed$feed_url,
    owner = list(
      name = x$params$feed$itunes_owner_name,
      email = x$params$feed$itunes_owner_email
    ),
    guid = x$params$feed$guid,
    value = x$params$feed$value,
    license = x$params$feed$license,
    funding = x$params$feed$funding
  )

  return(p_meta)
}

#' Import all episode metadata
#' @param input_dir full path to directory with episode markdown files
#' @name core
#' @return list of all episode metadata
#' @export
import_all_episodes <- function(input_dir = "content/episode") {
  box::use(purrr[map])
  # list all episode files
  episode_files <- list.files(path = input_dir, full.names = TRUE)

  # use purrr map to import all episode metadata
  episode_list <- map(episode_files, ~import_episode_metadata(.x))
  return(episode_list)
}

#' Generate podcsat RSS feed
#' @param podcast_metadata list of podcast metadata
#' @param episode_metadata list of episode metadata
#' @param output_file full path to output feed xml file
#' @name core
#' @return invisible output_file path
#' @export
gen_podcast_rss <- function(podcast_metadata, episode_metadata, output_file = "R/feed.xml") {
  # import package dependencies
  box::use(reticulate[...])
  box::use(purrr[map])

  # import python package functions
  pod2gen <- import("pod2gen")
  datetime <- import("datetime", convert = FALSE)
  dateutil.tz <- import("dateutil.tz")
  pytz <- import("pytz")

  # initialize feed with podcast metadata
  p_meta <- podcast_metadata

  p_authors <- list(
    pod2gen$Person(
      p_meta$owner$name,
      p_meta$owner$email
    )
  )

  p_owner <- pod2gen$Person(
    p_meta$owner$name,
    p_meta$owner$email
  )

  p_funding <- pod2gen$Funding(
    p_meta$funding$text,
    p_meta$funding$url
  )

  p_value <- pod2gen$Value(
    value_type = p_meta$value$type,
    method = p_meta$value$method,
    suggested = p_meta$value$suggested,
    recipients = map(p_meta$value$recipients, ~{
      pod2gen$Recipient(
        name = .x$name,
        type = .x$type,
        address = .x$address,
        customKey = .x$customKey,
        customValue = .x$customValue,
        split = .x$split
      )
    }))

  p_category <- pod2gen$Category(p_meta$category)
    # recipients = list(
    #   pod2gen$Recipient(
    #     name = "Test Person",
    #     address_type = "node",
    #     address = "hhhhhhhh"
    #   )
    # )

  p <- pod2gen$Podcast(
    name = p_meta$title,
    authors = p_authors,
    website = p_meta$website,
    copyright = p_meta$copyright,
    description = p_meta$description,
    is_serial = TRUE,
    language = p_meta$language,
    feed_url = p_meta$feed_url,
    explicit = p_meta$explicit,
    complete = FALSE,
    owner = p_owner,
    locked = FALSE,
    category = p_category
  )

  p$add_funding(p_funding)

  # TODO: Debugging episode constructs, will loop it later
  ep_sub <- episode_metadata[[1]]

  # grab publish date and translate into components
  ep_date <- parse_publish_date(ep_sub$date)
  ep_date_object <- datetime$datetime(
    ep_date$year,
    ep_date$month,
    ep_date$day,
    ep_date$hour,
    ep_date$minute,
    ep_date$second,
    tzinfo = datetime$timezone$utc
  )

  ep_obj <- pod2gen$Episode(
    title = ep_obj$title,
    summary = ep_obj$description,
    publication_date = ep_date_object
  )

}