#' Processing old episodes from Fireside
#' 
#' This script provides functions for processing the scraped fireside episode metadata and writing episode posts for the site
'.__module__.'

#' Import fireside json files
#' @param file full path to fireside json file
#' @param process run post-processing of json list
#' @name driver
#' @return list of episode metadata to go into yaml header
#' @export
import_fireside_json <- function(file, process = TRUE) {
  box::use(jsonlite[fromJSON])
  box::use(purrr[map, compact])
  box::use(stringr[str_pad])

  x <- fromJSON(file, simplifyVector = FALSE, simplifyDataFrame = FALSE)

  if (process) {
    # remove extra fields not necessary for post-processing
    x$guests <- NULL
    x$sponsors <- NULL
    x$slug <- NULL
    x$show_slug <- NULL
    x$show_name <- NULL
    x$header_image <- NULL
    x$categories <- NULL
    x$tags <- NULL
    x$podcast_alt_file <- NULL
    x$podcast_ogg_file <- NULL
    x$video_file <- NULL
    x$video_hd_file <- NULL
    x$video_mobile_file <- NULL
    x$youtube_link <- NULL
    x$jb_url <- NULL
    x$fireside_url <- NULL

    # remove extra elements from chapters slot
    x$podcast_chapters$chapters <- map(x$podcast_chapters$chapters, ~compact(.x))

    # change mp3 file to my version on S3 bucket
    x$podcast_file <- paste0("rwh", str_pad(x$episode, width = 3, pad = "0"), ".mp3")

    # add value block data
    x$value <- list(
      type = "lightning",
      method = "keysend",
      suggested = "0.0000005000",
      recipients = list(
        list(
          name = "rpodcast@getalby.com",
          type = "node",
          address = "030a58b8653d32b99200a2334cfe913e51dc7d155aa0116c176657a4f1722677a3",
          customKey = "696969",
          customValue = "0El4ZrgMqGemTCECGkUG",
          split = "100"
        )
      )
    )
  }
  return(x)
}

#' Import fireside episode shownotes HTML file and convert to markdown
#' @param input_file full path to fireside HTML shownotes file
#' @param output_file full path to output markdown file
#' @name driver
#' @return output file path invisibly
#' @export
import_fireside_shownotes <- function(input_file, output_file) {
  box::use(rmarkdown[pandoc_convert])
  # input file requires absolute path for esoteric reasons
  pandoc_convert(
    file.path(getwd(), input_file),
    to = "markdown_strict",
    output = output_file
  )
  invisible(output_file)
}

#' Create episode markdown file from fireside metadata scrape files
#' @param episode episode number in integer format
#' @param input_dir full path to directory with episode metadata
#' @param output_dir full path to episode directory to store markdown file
#' @name driver
#' @return output markdown file path invisibly
#' @export
create_episode_post <- function(
  episode = 1,
  input_dir = "fireside_rweekly_files/content/show/rweekly-highlights",
  output_dir = "content/episode"
) {
  # declare package/function dependencies
  box::use(stringr[str_pad])
  box::use(ymlthis[as_yml, use_yml_file, use_rmarkdown])
  box::use(withr[with_tempfile])

  # fireside metadata files have 4 digits for episode number
  fireside_episode <- str_pad(episode, width = 4, pad = "0")

  # import metadata json file
  x <- import_fireside_json(file.path(input_dir, paste0(fireside_episode, ".json")))

  # convert to yaml object
  post_yaml <- as_yml(x)

  # form output file path
  output_file <- file.path(output_dir, paste0(fireside_episode, ".md"))

  with_tempfile("tf", {
    import_fireside_shownotes(
      input_file = file.path(input_dir, paste0(fireside_episode, "_notes.html")),
      output_file = tf
    )

    use_rmarkdown(
      post_yaml,
      output_file,
      body = readLines(tf),
      open_doc = FALSE,
      overwrite = TRUE
    )
  })

  invisible(output_file)
}

#' Create episode posts from all or subset of previous fireside episodes
#' @param episodes vector of episode numbers to process
#' @name driver
#' @export
create_episodes <- function(episodes) {
  box::use(purrr[walk, map])
  walk(episodes, ~create_episode_post(.x))
}