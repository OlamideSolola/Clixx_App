data "template_file" "bootstrap" {
  template = file(format("%s/scripts/bootstrap.tpl", path.module))
  vars = {
    GIT_REPO="https://github.com/stackitgit/CliXX_Retail_Repository.git"
    MOUNT_POINT=var.MOUNT_POINT
    REGION=var.AWS_REGION
    FILE_SYSTEM_ID="fs-08c1be7a6d41588a1"
  }
  }
