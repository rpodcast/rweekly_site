#-----------------------------------------------------
# TODO: NOT WORKING for paws
# library(paws)

# s3 <- paws::s3(
#   config = list(
#     credentials = list(
#       creds = list(
#         access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
#         secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY")
#       )
#     ),
#     region = Sys.getenv("AWS_REGION"),
#     endpoint = "nyc3.digitaloceanspaces.com"
#   )
# )

# s3$list_buckets()
#------------------------------------------------------

#------------------------------------------------------
# botor version
#------------------------------------------------------
library(botor)

# using client implementation: a low-level interaction with AWS APIs
x <- botor_client(
  service = "s3",
  type = "client",
  region_name = "nyc3",
  endpoint_url = 'https://nyc3.digitaloceanspaces.com',
  aws_access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
  aws_secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY")
)

# list buckets
# doc: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-example-creating-buckets.html
buckets <- x$list_buckets()
buckets$Buckets |> View()

# list objects in bucket
bucket_objects <- x$list_objects(Bucket = "rweekly-highlights")
bucket_objects$Contents |> View()

# download a file
# arg1: bucket name
# arg2: object name in s3 to download (including folder/prefix)
# arg3: local file path to use for download
# doc: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-example-download-file.html
x$download_file("rpodcast-testing", "assets/rpodcast-hexagon.png", "rpodcast-hexagon.png")

# upload a file
# arg1: local file path to use for upload
# arg2: bucket name
# arg3: object name to use in s3 (if you want a folder/prefix, just add it to the path)
# doc: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-uploading-files.html
x$upload_file("play.R", "rpodcast-testing", "testfolder/play.R")

# verify file is availalble
x$download_file("rpodcast-testing", "testfolder/play.R", "play2.R")

# using resource implementation: a higher-level approach with AWS APIs
s3 <- boto3$resource(
  's3', 
  region_name = "nyc3",
  endpoint_url = 'https://nyc3.digitaloceanspaces.com',
  aws_access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
  aws_secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY")
)

library(reticulate)
obj <- s3$Object(bucket_name = "rpodcast-testing", key = "rpodcast_newlogo_itunes.png")
obj$key
obj$bucket_name

s3$Object(bucket_name = "rpodcast-testing", key = "silly.txt")

iter_next(s3$buckets$pages())


