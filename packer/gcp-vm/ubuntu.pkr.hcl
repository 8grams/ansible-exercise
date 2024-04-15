// To run
// init -> packer init .
// validate syntax -> packer validate .
// build -> packer build ubuntu.pkr.hcl

packer {
  required_plugins {
    // https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute
    googlecompute = {
      version = ">= 1.1.4"
      source = "github.com/hashicorp/googlecompute"

      // use provided credentials file 
      // credentials_file = "./google.json"
    }
  }
}

// https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute/latest/components/builder/googlecompute
source "googlecompute" "ubuntu" {
  project_id = var.project_id
  instance_name = "onxp-ubuntu-jammy"
  source_image = "ubuntu-2204-jammy-v20240319"
  ssh_username = "glendmaatita.me@gmail.com"
  zone = "us-central1-a"
  disk_size = 40
  machine_type = "e2-micro"
  disk_type = "pd-standard"
  communicator = "ssh"
}

build {
  name    = "onxp-packer-ubuntu"
  sources = [
    "source.googlecompute.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "BOOTCAMP=OnXP",
    ]

    inline = [
      "echo 'Using shell provisioner with inline command'",
      "sudo mkdir -p /opt/data",
      "sudo chmod 777 -R /opt/data",
      "echo \"Hello, $BOOTCAMP!\" > /opt/data/hello.txt",
      "sudo apt update -y && sudo apt install -y nginx certbot python3-certbot-nginx",
    ]
  }

  // [optional] save to gcs
  // post-processor "googlecompute-export" {
  //   paths = [
  //     "gs://onxp-terraform/vm/images/ubuntu-jammy.tar.gz",
  //   ]
  //   keep_input_artifact = true
  // }
}

variable "project_id" {
  type    = string
  default = "mashanz-software-engineering"
}
