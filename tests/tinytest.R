
if (requireNamespace("tinytest", quietly = TRUE)) {
  Sys.setenv(
    R_USER_CACHE_DIR = tempfile("tinyoauth_cache_"),
    R_USER_DATA_DIR = tempfile("tinyoauth_data_"),
    R_USER_CONFIG_DIR = tempfile("tinyoauth_config_")
  )
  tinytest::test_package("tinyoauth")
}
