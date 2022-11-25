resource "aws_launch_configuration" "jbolonlaunchconfig" {
  name                        = "skillup-jbolon-lc"
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_user
  key_name                    = var.key_name
  associate_public_ip_address = false
  security_groups             = [aws_security_group.jbolonwebsg.id]
  user_data                   = file("userdata.tpl")
}