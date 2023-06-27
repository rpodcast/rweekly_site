box::use(./R/fireside_process/driver)
box::reload(driver)

driver$import_fireside_json("/workspaces/rweekly_site/fireside_rweekly_files/content/show/rweekly-highlights/0125.json")

driver$import_fireside_shownotes(
  input_file = "fireside_rweekly_files/content/show/rweekly-highlights/0100_notes.html",
  output_file = "/workspaces/rweekly_site/R/0100_notes.md"
)

driver$create_episode_post(1)


driver$create_episodes(1:127)


box::use(./R/rss_process/core)

core$hms_convert("0:30:10")

box::reload(core)

x <- core$bucket_connect()

core$bucket_upload_file(con = x, file = "podcast.yaml", destination = "podcast.yaml")

core$bucket_download_file(
  con = x,
  object_name = "rss/feed.xml",
  destination = "feed2.xml"
)

core$parse_episode_shownotes("content/episode/0100.md")

#core$parse_media_info("/rweekly_media/rwh100.mp3")
#core$parse_publish_date("2023-06-21T01:45:00-04:00")

#core$import_episode_metadata("content/episode/0125.md")

podcast_metadata <- core$import_podcast_metadata("config.yaml")
episode_list <- core$import_all_episodes()
core$gen_podcast_rss(
  podcast_metadata = podcast_metadata,
  episode_metadata = episode_list
)