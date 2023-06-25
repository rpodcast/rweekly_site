box::use(./R/fireside_process/driver)

driver$import_fireside_json("/workspaces/rweekly_site/fireside_rweekly_files/content/show/rweekly-highlights/0125.json")

driver$import_fireside_shownotes(
  input_file = "fireside_rweekly_files/content/show/rweekly-highlights/0125_notes.html",
  output_file = "/workspaces/rweekly_site/R/0125_notes.md"
)

driver$create_episode_post(1)


driver$create_episodes(1:10)


box::use(./R/rss_process/core)

box::reload(core)

#core$parse_media_info("/rweekly_media/rwh100.mp3")
#core$parse_publish_date("2023-06-21T01:45:00-04:00")

#core$import_episode_metadata("content/episode/0125.md")

podcast_metadata <- core$import_podcast_metadata("config.yaml")
episode_list <- core$import_all_episodes()
core$gen_podcast_rss(
  podcast_metadata = podcast_metadata,
  episode_metadata = episode_list
)