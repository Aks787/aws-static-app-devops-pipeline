#Setting up Vpc network for my application to enhance the security 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
}

# Subnet
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public1_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public2_cidr
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

#route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#route table id
resource "aws_route_table_association" "route_association1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "route_association2"{
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_route.id
}

#security group for load balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  vpc_id      = aws_vpc.vpc.id

ingress {
  from_port   = 80
  protocol    = "TCP"
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
  }

egress {
  from_port       = 0
  protocol        = "-1"
  to_port         = 0
  cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group for ec2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  vpc_id      = aws_vpc.vpc.id

ingress {
  from_port = 80
  protocol  = "TCP"
  to_port   = 80
  security_groups = [aws_security_group.alb_sg.id]
  }
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [var.ssh_cidr]
}
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}

# configuring the template

resource "aws_launch_template" "template" {
  name          = "template"
  image_id      = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"
  
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id

  ]
  user_data = filebase64("${path.module}/user-data.sh")
}

#target group

resource "aws_lb_target_group" "target_grp" {
  name         = "target-grp"
  port         = 80
  protocol     = "HTTP"
  target_type  = "instance"
  vpc_id       = aws_vpc.vpc.id
}

#configure application load balancer
resource "aws_lb" "test" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [ 
    aws_subnet.public1.id,
    aws_subnet.public2.id
    ]
  enable_deletion_protection = false
}

#alb listeners
resource "aws_lb_listener" "alb_listeners" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_grp.arn
  }
}

#Configuring Auto scaling group
resource "aws_autoscaling_group" "asg" {
  name                      = "my-asg"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = [aws_subnet.public1.id, aws_subnet.public2.id]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  target_group_arns = [
  aws_lb_target_group.target_grp.arn
]

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }
}