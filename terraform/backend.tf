data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_iam_role" "backend_role" {
  name = "media-app-backend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = { Name = "media-app-backend-role" }
}

resource "aws_iam_instance_profile" "backend_instance_profile" {
  name = "media-app-backend-instance-profile"
  role = aws_iam_role.backend_role.name
}

resource "aws_launch_template" "backend" {
  name_prefix            = "media-app-backend-"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.backend_instance_profile.name
  }

  user_data = base64encode(<<-EOF
                  yum update -y
                  yum install -y httpd
                  systemctl start httpd
                  systemctl enable httpd
                  echo "OK" > /var/www/html/health
                  echo "Listen 3000" >> /etc/httpd/conf/httpd.conf
                  systemctl restart httpd
                  EOF
  )

  tags = { Name = "media-app-backend-instance" }

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "media-app-backend-instance" }
  }
}

resource "aws_autoscaling_group" "backend" {
  name                = "media-app-backend-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = aws_subnet.private[*].id

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.backend.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "media-app-backend-instance"
    propagate_at_launch = true
  }
}
