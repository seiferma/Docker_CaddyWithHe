variable "VERSION" {
  default = "latest"
}

group "default" {
  targets = ["default"]
}

target "default" {
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["quay.io/seiferma/caddy-he:${VERSION}"]
  args = {
    CADDY_VERSION = "${VERSION}"
  }
}
