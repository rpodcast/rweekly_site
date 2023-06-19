FROM ghcr.io/rocker-org/devcontainer/tidyverse:4.3

# key dependencies for utilities
RUN apt-get update -qq \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends libxt6 curl libglpk-dev libcurl4-openssl-dev libssl-dev libxml2-dev

# install R package dependencies
RUN install2.r renv blogdown reticulate httpgd languageserver ymlthis botor paws paws.s3 r2lambda box shiny rhino shinyvalidate shinyGizmo purrr markdown

# install rpython and pip3
RUN apt-get update \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends python3-setuptools python3-pip

RUN pip3 install python-dateutil boto3
RUN pip3 install 'git+https://gitlab.com/rpodcast/pod2gen'