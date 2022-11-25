#create security group
resource "aws_security_group" "jbolonbastionsg" {

  name        = "skillup-jbolon-bastion-sg"
  description = "SG for j.bolon Bastion"
  vpc_id      = aws_vpc.jbolonvpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.req_tags, {
    Name = "skillup-jbolon-bastion-sg"
    }
  )
}

resource "aws_security_group" "jbolonalbsg" {

  name        = "skillup-jbolon-alb-sg"
  description = "SG for j.bolon ALB"
  vpc_id      = aws_vpc.jbolonvpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.req_tags, {
    Name = "skillup-jbolon-alb-sg"
    }
  )
}

resource "aws_security_group" "jbolonwebsg" {

  name        = "skillup-jbolon-web-sg"
  description = "SG for j.bolon Webserver"
  vpc_id      = aws_vpc.jbolonvpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.req_tags, {
    Name = "skillup-jbolon-web-sg"
    }
  )
}

#security group bastion rule
resource "aws_security_group_rule" "jbolonbastionssh" {
  type              = "ingress"
  from_port         = 6522
  to_port           = 6522
  protocol          = "tcp"
  cidr_blocks       = [var.my_home_ip]
  security_group_id = aws_security_group.jbolonbastionsg.id
}

#security group alb rule
resource "aws_security_group_rule" "jbolonalbhttp" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.my_home_ip]
  security_group_id = aws_security_group.jbolonalbsg.id
}

#security group web rule
resource "aws_security_group_rule" "jbolonwebhttp" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jbolonalbsg.id
  security_group_id        = aws_security_group.jbolonwebsg.id
}

resource "aws_security_group_rule" "jbolonwebssh" {
  type                     = "ingress"
  from_port                = 6522
  to_port                  = 6522
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jbolonbastionsg.id
  security_group_id        = aws_security_group.jbolonwebsg.id
}