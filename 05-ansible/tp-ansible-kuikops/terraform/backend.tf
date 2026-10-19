terraform {
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/87244526/terraform/state/tp-ansible"
    lock_address   = "https://gitlab.com/api/v4/projects/87244526/terraform/state/tp-ansible/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/87244526/terraform/state/tp-ansible/lock"

    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
