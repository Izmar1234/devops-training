# ============================================================
# CLÉ PUBLIQUE SSH ENREGISTRÉE DANS AWS EC2
# ============================================================

resource "aws_key_pair" "main" {
  key_name = "${local.name_prefix}_key_pair"

  # pathexpand transforme "~" en chemin absolu.
  # file lit uniquement le contenu de la clé publique.
  public_key = file(
    pathexpand(var.ssh_public_key_path)
  )

  tags = {
    Name = "${local.name_prefix}_key_pair"
    Role = "ssh-access"
  }
}
