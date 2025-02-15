schema = "1"

project "nomad-driver-podman" {
  team = "nomad"
  slack {
    notification_channel = "C03B5EWFW01"
  }
  github {
    organization = "hashicorp"
    repository   = "nomad-driver-podman"
    release_branches = [
      "main",
      "release/**",
    ]
  }
}

event "merge" {
  // "entrypoint" to use if build is not run automatically
  // i.e. send "merge" complete signal to orchestrator to trigger build
}

event "build" {
  depends = ["merge"]
  action "build" {
    organization = "hashicorp"
    repository   = "nomad-driver-podman"
    workflow     = "build"
  }
}

event "upload-dev" {
  depends = ["build"]
  action "upload-dev" {
    organization = "hashicorp"
    repository   = "crt-workflows-common"
    workflow     = "upload-dev"
    depends      = ["build"]
  }

  notification {
    on = "fail"
  }
}

event "security-scan-binaries" {
  depends = ["upload-dev"]
  action "security-scan-binaries" {
    organization = "hashicorp"
    repository   = "crt-workflows-common"
    workflow     = "security-scan-binaries"
    config       = "security-scan.hcl"
  }

  notification {
    on = "fail"
  }
}

event "sign" {
  depends = ["security-scan-binaries"]
  action "sign" {
    organization = "hashicorp"
    repository   = "crt-workflows-common"
    workflow     = "sign"
  }

  notification {
    on = "fail"
  }
}

event "verify" {
  depends = ["sign"]
  action "verify" {
    organization = "hashicorp"
    repository   = "crt-workflows-common"
    workflow     = "verify"
  }

  notification {
    on = "always"
  }
}

event "fossa-scan" {
  depends = ["verify"]
  action "fossa-scan" {
    organization = "hashicorp"
    repository   = "crt-workflows-common"
    workflow     = "fossa-scan"
  }
}

## These are promotion and post-publish events
## they should be added to the end of the file after the verify event stanza.

event "trigger-staging" {
  // This event is dispatched by the bob trigger-promotion command
  // and is required - do not delete.
}

event "promote-staging" {
  depends = ["trigger-staging"]
  action "promote-staging" {
    organization = "hashicorp"
    repository   = "crt-workflows-common"
    workflow     = "promote-staging"
    config       = "release-metadata.hcl"
  }

  notification {
    on = "always"
  }
}

event "trigger-production" {
  // This event is dispatched by the bob trigger-promotion command
  // and is required - do not delete.
}

event "promote-production" {
  depends = ["trigger-production"]
  action "promote-production" {
    organization = "hashicorp"
    repository   = "crt-workflows-common"
    workflow     = "promote-production"
  }

  notification {
    on = "always"
  }
}
