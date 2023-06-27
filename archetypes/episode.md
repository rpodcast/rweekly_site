---
title: ""
description: ""
date: {{ .Date }}
podcast_file: "###.mp3" # the name of the podcast file, after the media prefix.
podcast_duration: "00:00"
podcast_bytes: ""
episode_image: "img/episode/default.jpg"
images: ["img/episode/default-social.jpg"]
hosts: 
- enantz
- mthomas
aliases: ["/##"]
youtube: ""
explicit: no
podcast_chapters:
  version: 1.1.0
  chapters:
    - startTime: 0
      title: "Intro"
    - startTime: 180
      title: "Example Chapter"
value:
  type: lightning
  method: keysend
  suggested: "0.00000005000"
  recipients:
    - name: rpodcast@getalby.com
      type: node
      address: 030a58b8653d32b99200a2334cfe913e51dc7d155aa0116c176657a4f1722677a3
      customKey: 696969
      customValue: 0El4ZrgMqGemTCECGkUG
      split: 100
---
