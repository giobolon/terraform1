#create VPC
resource "aws_vpc" "jbolonvpc" {
  cidr_block       = "10.100.0.0/16"
  instance_tenancy = "default"

  tags = merge(var.req_tags,
    {
      Name = "skillup-j.bolon-vpc"
    }
  )
}

#create internet gateway
resource "aws_internet_gateway" "jbolonigw" {
  vpc_id = aws_vpc.jbolonvpc.id

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-igw"
    }
  )
}

#create public subnets
resource "aws_subnet" "jbolonpubsub2a" {
  vpc_id            = aws_vpc.jbolonvpc.id
  availability_zone = var.region_a
  cidr_block        = "10.100.1.0/24"

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-pub-2a"
    }
  )
}

resource "aws_subnet" "jbolonpubsub2b" {
  vpc_id            = aws_vpc.jbolonvpc.id
  availability_zone = var.region_b
  cidr_block        = "10.100.2.0/24"

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-pub-2b"
    }
  )
}

#create private subnets
resource "aws_subnet" "jbolonprivsub2a" {
  vpc_id            = aws_vpc.jbolonvpc.id
  availability_zone = var.region_a
  cidr_block        = "10.100.3.0/24"

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-priv-2a"
    }
  )
}

resource "aws_subnet" "jbolonprivsub2b" {
  vpc_id            = aws_vpc.jbolonvpc.id
  availability_zone = var.region_b
  cidr_block        = "10.100.4.0/24"

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-priv-2b"
    }
  )
}

#create db subnets
resource "aws_subnet" "jbolondbsub2a" {
  vpc_id            = aws_vpc.jbolonvpc.id
  availability_zone = var.region_a
  cidr_block        = "10.100.5.0/24"

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-db-2a"
    }
  )
}

resource "aws_subnet" "jbolondbsub2b" {
  vpc_id            = aws_vpc.jbolonvpc.id
  availability_zone = var.region_b
  cidr_block        = "10.100.6.0/24"

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-db-2b"
    }
  )
}

#create nat gateway
resource "aws_nat_gateway" "jbolonnat" {
  allocation_id     = aws_eip.jboloneip.id
  subnet_id         = aws_subnet.jbolonpubsub2a.id
  connectivity_type = "public"

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-nat"
    }
  )
}

#create elastic ip
resource "aws_eip" "jboloneip" {
  vpc = true
}

#create route tables
resource "aws_route_table" "jbolonpubrt" {
  vpc_id = aws_vpc.jbolonvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jbolonigw.id
  }

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-pub-rt"
    }
  )
}

resource "aws_route_table" "jbolonprivrt" {
  vpc_id = aws_vpc.jbolonvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.jbolonnat.id
  }

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-priv-rt"
    }
  )
}

#associate route table to subnet
resource "aws_route_table_association" "jbolonpubasoc1" {
  subnet_id      = aws_subnet.jbolonpubsub2a.id
  route_table_id = aws_route_table.jbolonpubrt.id
}
resource "aws_route_table_association" "jbolonpubasoc2" {
  subnet_id      = aws_subnet.jbolonpubsub2b.id
  route_table_id = aws_route_table.jbolonpubrt.id
}
resource "aws_route_table_association" "jbolonprivasoc3" {
  subnet_id      = aws_subnet.jbolonprivsub2a.id
  route_table_id = aws_route_table.jbolonprivrt.id
}
resource "aws_route_table_association" "jbolonprivasoc4" {
  subnet_id      = aws_subnet.jbolonprivsub2b.id
  route_table_id = aws_route_table.jbolonprivrt.id
}

#create VPC endpoint
resource "aws_vpc_endpoint" "jbolons3endpoint" {
  vpc_id            = aws_vpc.jbolonvpc.id
  service_name      = "com.amazonaws.ap-southeast-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.jbolonpubrt.id, aws_route_table.jbolonprivrt.id]

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-s3ep"
    }
  )
}

#create bastion instance ec2
resource "aws_instance" "jbolonbastion" {
  ami                         = var.ami_id
  subnet_id                   = aws_subnet.jbolonpubsub2b.id
  instance_type               = var.instance_type
  availability_zone           = var.region_b
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jbolonbastionsg.id]
  iam_instance_profile        = var.iam_user
  user_data                   = file("userdata.tpl")


  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-bastion"
    }
  )
}

#create load balancer
resource "aws_lb" "jbolonalb" {
  name               = "skillup-jbolon-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jbolonalbsg.id]
  subnets            = [aws_subnet.jbolonpubsub2a.id, aws_subnet.jbolonpubsub2b.id]

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-alb"
    }
  )
}

#create target group
resource "aws_lb_target_group" "jbolontg" {
  name        = "skillup-jbolon-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.jbolonvpc.id

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 200
    matcher             = "200-499"
  }

  tags = merge(var.req_tags, {
    Name = "skillup-j.bolon-tg"
    }
  )
}

#create auto scaling group
resource "aws_autoscaling_group" "jbolonasg" {
  name                      = "skillup-j.bolon-asg"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.jbolontg.arn]
  launch_configuration      = aws_launch_configuration.jbolonlaunchconfig.name
  vpc_zone_identifier       = [aws_subnet.jbolonprivsub2a.id, aws_subnet.jbolonprivsub2b.id]

  tag {
    key                 = "Name"
    value               = "skillup-j.bolon-web"
    propagate_at_launch = true
  }

  tag {
    key                 = "GBL_CLASS_0"
    value               = "SERVICE"
    propagate_at_launch = true
  }
  tag {
    key                 = "GBL_CLASS_1"
    value               = "TEST"
    propagate_at_launch = true
  }
}

#attach asg to lb
resource "aws_lb_listener" "jbolonlistener" {
  load_balancer_arn = aws_lb.jbolonalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jbolontg.arn
  }
}

