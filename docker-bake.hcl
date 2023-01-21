group "default" {
  targets = ["manager", "worker"]
}

target "manager" {
  inherits = ["docker-metadata-action-manager"]
  dockerfile = "Dockerfile"
  target = "flamenco-manager"
}

target "worker" {
  inherits = ["docker-metadata-action-worker"]
  dockerfile = "Dockerfile"
  target = "flamenco-worker"
}

# Targets to allow injecting customizations from Github Actions.

target "docker-metadata-action-manager" {}
target "docker-metadata-action-worker" {}
