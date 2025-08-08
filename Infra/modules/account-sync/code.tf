# ----------------------------------------------------------------------------------------------------------------------
# Upload the code
# ----------------------------------------------------------------------------------------------------------------------
data "archive_file" "source_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function_source"
  output_path = "/tmp/function_source.zip"
}

resource "google_storage_bucket_object" "source_object" {
  name   = "source.zip"
  bucket = google_storage_bucket.source_bucket.name
  source = data.archive_file.source_zip.output_path

  depends_on = [ google_storage_bucket.source_bucket ]
}
