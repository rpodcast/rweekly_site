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
  # declare dependencies 
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

#' parse episode media file attributes
#' @param file full path to episode mp3 file stored locally
#' @name core
#' @return list of media metadata compatible with pod2gen Media object
#' @export
parse_media_info <- function(file, url_prefix = "https://rweekly-highlights.nyc3.cdn.digitaloceanspaces.com/media/audio/") {
  # declare dependencies
  box::use(reticulate[...])
  tinytag <- import("tinytag")

  # derive attributes
  x_url <- paste0(url_prefix, basename(file))
  x_size <- file.info(file)$size
  x_type <- "audio/mpeg"
  x_duration <- tinytag$TinyTag$get(file)$duration

  return(
    list(
      url = x_url,
      size = as.integer(x_size),
      type = x_type,
      duration = x_duration
    )
  )
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
    subtitle = x$params$feed$itunes_subtitle,
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
#' @param reverse_order flag to reverse order of items. This is typically
#'   required for pocdast RSS feeds to have items from latest to earliest
#' @name core
#' @return list of all episode metadata
#' @export
import_all_episodes <- function(input_dir = "content/episode", reverse_order = TRUE) {
  box::use(purrr[map, map_chr])
  # list all episode files
  episode_files <- list.files(path = input_dir, full.names = TRUE)

  # use purrr map to import all episode metadata
  episode_list <- map(episode_files, ~import_episode_metadata(.x))
  names(episode_list) <- purrr::map_chr(episode_list, ~{
    as.character(.x$episode)
  })
  if (reverse_order) episode_list <- rev(episode_list)
  return(episode_list)
}

#' Generate podcsat RSS feed
#' @param podcast_metadata list of podcast metadata
#' @param episode_metadata list of episode metadata
#' @param local_media_path local directory of podcast media files
#' @param output_file full path to output feed xml file
#' @name core
#' @return invisible output_file path
#' @export
gen_podcast_rss <- function(
  podcast_metadata, 
  episode_metadata, 
  local_media_path = "/rweekly_media",
  output_file = "R/feed.xml") {
  # import package dependencies
  box::use(reticulate[...])
  box::use(purrr[map, walk])

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
        address_type = .x$type,
        address = .x$address,
        #customKey = .x$customKey,
        #customValue = .x$customValue,
        split = .x$split
      )
    }))

  p_category <- pod2gen$Category(p_meta$category)

  p_license <- pod2gen$License(
    identifier = p_meta$license$name,
    url = p_meta$license$url
  )

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
    license = p_license,
    complete = FALSE,
    owner = p_owner,
    locked = FALSE,
    value = p_value,
    category = p_category
  )

  p$add_funding(p_funding)

  # TODO: Debugging episode constructs, will loop it later
  walk(episode_metadata, ~{
    ep_sub <- .x
    
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

    ep_media_info <- parse_media_info(file.path(local_media_path, ep_sub$podcast_file))
    ep_media_obj <- pod2gen$Media(
      url = ep_media_info$url,
      size = ep_media_info$size,
      type = ep_media_info$type,
      duration = datetime$timedelta(ep_media_info$duration)
    )

    ep_value_obj <- pod2gen$Value(
      value_type = ep_sub$value$type,
      method = ep_sub$value$method,
      suggested = ep_sub$value$suggested,
      recipients = map(ep_sub$value$recipients, ~{
        pod2gen$Recipient(
          name = .x$name,
          address_type = .x$type,
          address = .x$address,
          #customKey = .x$customKey,
          #customValue = .x$customValue,
          split = .x$split
        )
      }))

    ep_obj <- pod2gen$Episode(
      title = ep_sub$title,
      subtitle = ep_sub$description,
      summary = ep_sub$description,
      episode_number = ep_sub$episode,
      publication_date = ep_date_object,
      media = ep_media_obj,
      value = ep_value_obj
    )

    # add episode to podcast object
    p$add_episode(ep_obj)
  })

  # create RSS file
  p$rss_file(output_file)
}