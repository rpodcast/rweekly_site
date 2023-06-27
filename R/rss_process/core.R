#' Core functions for RSS Feed and blog processing
#' 
#' This script provides utility functions used during the
#' processing of web site episode files as well as 
#' generating the RSS feed of the podcast istelf
'.__module__'

#' establish connection to podcast S3 bucket
#' @param endpoint_url URL of S3 endpoint
#' @return connection object
#' @export
bucket_connect <- function(endpoint_url = "https://nyc3.digitaloceanspaces.com") {
  # declare dependencies
  box::use(botor[botor_client])
  x <- botor_client(
    service = "s3",
    type = "client",
    region_name = "nyc3",
    endpoint_url = 'https://nyc3.digitaloceanspaces.com',
    aws_access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY")
  )
  return(x)
}

#' upload file to S3 bucket
#' @param con connection object for S3 bucket
#' @param file full path to local file to upload
#' @param destination location in bucket to use for upload key
#' @param bucket string for bucket name
#' @param set_public flag to enable public access for bucket file
#' @return invisible result of upload
#' @export
bucket_upload_file <- function(
  con,
  file,
  destination,
  bucket = "rweekly-highlights",
  set_public = TRUE) {
    box::use(botor[...])

    if (!file.exists(file)) stop("Specified local file does not exist", call. = FALSE)

    if (set_public) {
      public_string <- list(ACL = "public-read")
    } else {
      public_string <- NULL
    }
    con$upload_file(file, bucket, destination, ExtraArgs = public_string)
}

#' download file from S3 bucket
#' @param con connection object for S3 bucket
#' @param object_name location of file in S3 bucket
#' @param destination_file full path to local copy of file
#' @param bucket string for bucket name
#' @return invisible local destination file path
#' @export
bucket_download_file <- function(
  con,
  object_name,
  destination_file,
  bucket = "rweekly-highlights") {
    box::use(botor[...])

    con$download_file(bucket, object_name, destination_file)
}

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

#' convert hms notation into total seconds
#' @param timestamp string of time in hours:minutes:seconds notation
#' @return total number of seconds as integer
#' @export
hms_convert <- function(timestamp) {
  box::use(lubridate[hms, period_to_seconds])

  x <- period_to_seconds(hms(timestamp))
  return(x)
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

#' parse episode shownotes from markdown file
#' @param file full path to episode markdown file
#' @name core
#' @return character vector of HTML lines
#' @export
parse_episode_shownotes <- function(file) {
  box::use(markdown[mark])
  box::use(withr[with_tempfile])
  box::use(readr[read_lines, read_file])

  lines <- read_lines(file)
  yaml_delim <- grep("^---", lines)
  if (length(yaml_delim) > 1) {
    lines <- lines[(yaml_delim[2] + 1):length(lines)]
  }
  
  with_tempfile("tf", {
    mark(text = lines, output = tf)
    read_file(tf)
  })
  #mark(text = lines)
}

#' import yaml metadata from episode file
#' @param file full path to episode markdown file
#' @name core
#' @return list of episode metadata from yaml header
#' @export
import_episode_metadata <- function(file) {
  box::use(rmarkdown[yaml_front_matter])

  x <- yaml_front_matter(file)
  # append shownotes as another element
  x$shownotes <- parse_episode_shownotes(file)

  # construct link
  x$link <- paste0("https://podcast.rweekly.org/", x$episode)
  return(x)
}

#' Create podcast episode JSON file with chapter information
#' @param episode_metadata list of podcast episode metadata from yaml of markdown file
#' @param upload_to_s3 flag to upload chapters JSON file to s3 bucket. If false, 
#'   chapters file will be stored locally
#' @param bucket string of bucket name
#' @return invisible
#' @export
create_chapters_json <- function(episode_metadata, upload_to_s3 = TRUE, bucket = "rweekly-highlights") {
  box::use(purrr[map])
  box::use(jsonlite[toJSON])
  box::use(stringr[str_detect])

  # exit function if podcast_chapters yaml field does not exist
  if (!"podcast_chapters" %in% names(episode_metadata)) {
    message("no chapters declared. Exiting function")
    return(NULL)
  }

  # if chapters are writting in HMS notation, convert them to total seconds
  x <- episode_metadata$podcast_chapters$chapters
  episode_metadata$podcast_chapters$chapters <- map(x, ~{
    if (str_detect(.x$startTime, ":")) {
      .x$startTime <- hms_convert(.x$startTime)
    }
    return(.x)
  })
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
#' @param publish_feed flag to indicate whether to publish RSS file 
#'   to S3 bucket
#' @param bucket Name of S3 bucket
#' @param verbose flag to show verbose output when adding episodes to feed
#' @name core
#' @return invisible output_file path
#' @export
gen_podcast_rss <- function(
  podcast_metadata, 
  episode_metadata, 
  local_media_path = "/rweekly_media",
  output_file = "R/feed.xml",
  publish_feed = TRUE,
  bucket = "rweekly-highlights",
  verbose = FALSE) {
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
    image = p_meta$image,
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
    if (verbose) message(ep_sub$episode)
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
      summary = ep_sub$shownotes,
      long_summary = ep_sub$shownotes,
      link = ep_sub$link,
      episode_number = ep_sub$episode,
      publication_date = ep_date_object,
      media = ep_media_obj,
      value = ep_value_obj
    )

    # add episode to podcast object
    p$add_episode(ep_obj)
  })

  # create local RSS file
  p$rss_file(output_file)

  # publish feed to s3 bucket if requested
  if (publish_feed) {
    bucket_upload_file(
      con = bucket_connect(),
      file = output_file,
      destination = paste0("rss/", basename(output_file))
    )
  }
}