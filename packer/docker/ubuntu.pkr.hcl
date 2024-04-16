// To run
// init -> packer init .
// validate syntax -> packer validate .
// build -> packer build ubuntu.pkr.hcl
// run -> docker run -it <IMAGE ID> -c "/bin/sh

packer {
  required_plugins {
    docker = {
      // optional
      version = ">= 1.0.8"

      // more info: https://developer.hashicorp.com/packer/docs/builders
      source = "github.com/hashicorp/docker"
    }
  }
}

// builder type: docker, more info: https://developer.hashicorp.com/packer/integrations/hashicorp/docker
// builder name: ubuntu
source "docker" "ubuntu" {
  // base image, Packer will run it as container and do the provisioning
  image  = var.docker_image

  // export the provisionied container to docker image
  commit = true
}

// will execute after container running
build {
  name    = "onxp-packer-ubuntu"
  // from source block above
  sources = [
    "source.docker.ubuntu"
  ]

  // list of provisioners available: https://developer.hashicorp.com/packer/docs/provisioners
  provisioner "shell" {
    // add env variables
    environment_vars = [
      "BOOTCAMP=OnXP",
    ]

    // inline command shell
    inline = [
      "echo 'Using shell provisioner with inline command'",
      "mkdir -p /opt/data && echo \"Hello, $BOOTCAMP!\" > /opt/data/hello.txt",
    ]
  }

  // executed after container provisioned and commited
  post-processor "docker-tag" {
    repository = "glendmaatita/ubuntu-jammy"
    tags       = ["stable"]
    only       = ["docker.ubuntu"]
  }

  // get artifact from build and import to local docker registry
  post-processor "docker-import" {
    repository = "glendmaatita/ubuntu-jammy"
    tag = "stable"
  }

  // push to docker registry, must define docker-import as well
  // post-processor "docker-push" {
  //   login = true // set true if using hub docker
  //   login_username = "user"
  //   login_password = "password"
  // }
}

variable "docker_image" {
  type    = string
  default = "ubuntu:jammy"
}
