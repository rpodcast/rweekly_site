# RSS Feed notes

## Podcast RSS Items

| Parameter   | RSS tag                          | Castanet config value                                      | pod2gen function                                        |
| ----------- | -------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------- |
| Description | `<description>`                  | params -> description                                      | `Podcast().description = "Example Description"`         |
| Language    | `<language>`                     | params -> feed -> language                                 | `Podcast().language = "en-us"`                          |
| Title       | `<title>`                        | title                                                      | `Podcast().name = "Example Podcast"`                    |
| Explicit    | `<itunes:explicit>`              | params -> explicit                                         | `Podcast().explicit = False`                            |
| Copyright   | `<copyright>`                    | params -> feed -> copyright                                | `Podcast().copyright = "cc-by"`                         |
| Author      | `<itunes:author>`                | params -> feed -> itunes_author                            | TBD                                                     |
| Category    | `<itunes:category text='News'/>` | params -> feed -> itunes_top_category                      | `Podcast().category = Category("Technology")`           |
| Image       | `<itunes:image href="path" />`   | params -> feed -> itunes_image                             | `Podcast().image = "path"`                              |
| Owner       | `<itunes:owner </itunes_owner>`  | params -> feed -> itunes_owner_name and itunes_owner_email | `Podcast().owner = Person("Name", "email")`             |
| GUID        | `<podcast:guid>`                 | None                                                       | `Podcast().guid = "kfdjldslj"`                          |
| Value       | `<podcast:value>>`               | None                                                       | `Podcast().value = Value()`                             |
| License     | `<podcast:license>`              | None                                                       | `Podcast().license = License("name of license", "url")` |
| Funding     | `<podcast:funding>`              | None                                                       | `Podcast().add_funding(Funding("text", "url"))`         |
| Trailer     | `<podcast:trailer>`              | None                                                       | `Podcast().add_trailer(Trailer(...))`                   |
| Medium      | `<podcast:medium>`               | None                                                       | None                                                    |
| Locked      | `<podcast:locked>`               | None                                                       | `Podcast().locked = false`                              |
|             |                                  |                                                            |                                                         |

## Episode RSS Items

| Parameter              | RSS tag                       | Castanet yaml value                           | pod2gen function                                        |
| ---------------------- | ----------------------------- | --------------------------------------------- | ------------------------------------------------------- |
| Description            | `<description>`               | description                                   | `Episode().summary = "My Summary"`                      |
| Summary                | `<itunes:summary>`            | None                                          | `Episode().summary = "My Summary"`                      |
| Title                  | `<title>`                     | title                                         | `Episode().title = "Title"`                             |
| Author                 | `<itunes:author>`             | author                                        | `Episode().authors = [Person("Joe Bob")]`               |
| Image                  | `<itunes:image>`              | None                                          | `Episode().image = "path"`                              |
| Guid                   | `<guid>`                      | guid                                          | Assume it is episode item URL                           |
| Publish Date           | `<pubDate>`                   | date                                          | `Episode().publication_date = datetime.datetime()`      |
| Explicit               | `<itunes:explicit>`           | explicit                                      | `Episode().explicit = False`                            |
| Link                   | `<link>`                      | None                                          | `Episode().link = "path"`                               |
| License                | `<podcast:license>`           | None                                          | `Episode().license = License("name of license", "url")` |
| Media                  | `<enclosure>`                 | podcast_file, podcast_duration, podcast_bytes | `Episode().media = Media()`                             |
| Alternate Enclosure(s) | `<podcast:alternateEnclosure` | None                                          | `Episode().add_alternate_media(AlternateMedia())`       |
| Soundbite              | `<podcast:soundbite>`         | None                                          | `Episode().add_soundbite(Soundbite())`                  |
| Transcript             | `<podcast:transcript>`        | transcript                                    | `Episode().add_transcript(Transcript())`                |
| Chapters               | `<podcast:chapters>`          | None                                          | `Episode().chapters_json = "path/to/json_file.json"`    |
| Value                  | `<podcast:value>`             | None                                          | `Episode().value = Value()`                             |
|                        |                               |                                               |                                                         |

### Episode Assorted Notes

* Media type example in pod2gen: `Media(url = "http://path/to/file.mp3", size = 12121212, type = "audio/mpeg", duration = timedelta(hours = 1, minutes = 2, seconds = 36))`
* Alternate Media object in pod2gen (only type and length are required parameters):

```python
am = AlternateMedia(
  type = "audio/mp4",
  length = 432000000,
  bitrate = 128000,
  height = 1080,
  lang = "en-US",
  title = "Standard",
  rel = "Off stage",
  codecs = "mp4a.40.2",
  default = False,
  encryption = "pgp-signature",
  signature = "sha384-klsdklsdlksdklds"
)
```

* Soundbite object in pod2gen requires start time and duration: `soundbite_1 = Soundbite(start_time = 1234.5, duration = 42.25, text = "This matters")` 
* Transcripts in castanet Hugo theme must be stored in the site files (recommend static directory) and html based
* Transcript object in pod2gen requres url and type parameters: 

```python
t = Transcript(
  url = "https://example.com/transcript_sample.txt",
  type = "text/html"
)
```


* Name
* Description
* Language
* Title
* Explicit
* Copyright
* Itunes:Author
* Itunes:Category
* Itunes:Image (URL to image file)
* Itunes:Owner (name and email)
* Itunes:Type (episodic or serial)
* podcast:guid (bb28afcc-137e-5c66-b231-4ffad7979b44)
* podcast:Value
* podcast:License
* podcast:chapters
* podcast:funding
* podcast:trailer
* podcast:medium (default is podcast)
* podcast:locked (no)

## Episode RSS Items