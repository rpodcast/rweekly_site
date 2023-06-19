library(jsonlite)



m_text <- "
## Hello World

I am markdown text. Here is some __bold__ text.

* Item 1
* Item 2

And how about a [link](https://rweekly.org) too?
"

markdown::mark(text = m_text)
