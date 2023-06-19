# load modules
from shiny import *

categories = {"Science": "Science", "Technology": "Technology"}

app_ui = ui.page_fluid(
  ui.panel_title("Podcast RSS Admin"),
  ui.navset_pill_list(
    ui.nav(
      "Overview",
      ui.h3("Welcome Page with metrics coming")
    ),
    ui.nav(
      "Podcast Info",
      ui.row(
        ui.h2("Podcast Overall Tags"),
        ui.input_text("podcast_name", "Name", value="Residual Snippets"),
        ui.input_text("podcast_website", "Website", value="https://residual-snippets.org"),
        ui.input_text_area("podcast_description", "Description", value = "Musings on R, data science, linux. and life"),
        ui.input_checkbox("podcast_explicit", "Explicit", value=False),
        ui.input_text("podcast_image_link", "Cover Art Link", value="https://rpodcast-testing.nyc3.cdn.digitaloceanspaces.com/rpodcast_newlogo_itunes.png"),
        ui.input_checkbox("podcast_view_image", "Show Image", value=True),
        ui.panel_conditional(
          "input.podcast_view_image",
          ui.output_ui("podcast_image_placeholder")
        ),
        ui.input_checkbox("podcast_advanced_ui", "Show Advanced Parameters", value=False),
        ui.panel_conditional(
          "input.podcast_advanced_ui",
          ui.input_text("podcast_copyright", "Copyright", value = "2023 Eric Nantz"),
          ui.input_text("podcast_language", "Language", value = "en-US"),
          # TODO: Make a module out of authors and use dynamic UI to populate more or less
          # See Joe's dynamic UI example
          # https://github.com/jcheng5/PyDataNYC2022-demos
          ui.input_text("podcast_author_name", "Author Name", value="Eric Nantz"),
          ui.input_text("podcast_author_email", "Author Email Address", value="theRcast@gmail.com"),
          ui.input_text("podcast_feed_url", "Feed URL", value="https://residual-snippets.org/feeds/podcast.rss"),
          ui.input_selectize("podcast_category", "Category", categories)
        )
      )
    ),
    widths=(3,9)
  )
)

def server(input, output, session):
  @output
  @render.ui
  def podcast_image_placeholder():
    x = input.podcast_image_link()
    return ui.img({"src": x, "alt": "Cover Art", "width": "100px"})

app = App(app_ui, server)
