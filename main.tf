# Creating an EC2 Instance
resource "aws_instance" "My-Clixx-server" {
  ami = var.ami
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance-sg.id ]
  user_data = data.template_file.bootstrap.rendered
  user_data_replace_on_change = true
  tags = {
    Name = "CLIXX_Application_SERVER_TF_3"
  }
}
# Creating a security group to allow incoming to our EC2 instance
resource "aws_security_group" "instance-sg" {
    name = "terraform-stack-web2"
    description = "Allows incoming traffic to the application through HTTP"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow SSH connection"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow mysql traffic"
        from_port = "3306"
        to_port = "3306"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    
    }
    ingress {
        description = "EFS mount target"
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress { 
        description = "Allow all outbound traffic from the ec2 instance"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
    egress {
        description = "Allow outbound traffic to EFS"
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# # Declaring the public Key pair
# resource "aws_key_pair" "Stack_KP" {
#   key_name   = "stackkp"
#   public_key = file(var.PATH_TO_PUBLIC_KEY)
# }


# # Declaring the private key
# resource "aws_key_pair" "priv_ssh_key" {
#   key_name = var.PATH_TO_PRIVATE_KEY
#   public_key = file(var.PATH_TO_PRIVATE_KEY)
  
#}

# # Getting subnet
# resource "aws_subnet" "mysubnet" {
#   vpc_id = data.aws_vpc.default-vpc.id
#   availability_zone = "us-east-1a"
#   cidr_block = "10.0.0.0/24
#   map_public_ip_on_launch = "true"
#}

#Creating EFS 
resource "aws_efs_file_system" "clixx-efs" {
  creation_token = "clixxEFS"
  tags = {
    Name = "EFS"
  }
}

# Defining mount target
resource "aws_efs_mount_target" "efs-mount" {
  file_system_id = aws_efs_file_system.clixx-efs.id
  subnet_id = var.subnet
  security_groups = [ aws_security_group.instance-sg.id ]
}


# Creating the Launch template for the Auto Scaling Group
resource "aws_launch_configuration" "Clixx-ASG-LC" {
    image_id = var.ami
    instance_type = "t2.micro"
    security_groups = [ aws_security_group.instance-sg.id ]
    user_data = data.template_file.bootstrap.rendered
    lifecycle {create_before_destroy= true}
  
}

# Creating the Auto Scaling Group
resource "aws_autoscaling_group" "CliXX-ASG" {
  launch_configuration = aws_launch_configuration.Clixx-ASG-LC.name
  vpc_zone_identifier = data.aws_subnets.default-subnets.ids
 target_group_arns = [aws_lb_target_group.ClixxTFTG.arn]
  health_check_type = "ELB"
  min_size = 2
  max_size = 10
  tag {
    key = "Name"
    value = "Clixx-TF-ASG"
    propagate_at_launch = true
  }
}

# Getting the VPC
data "aws_vpc" "default-vpc" {
  default = true
}

# Getting the subnet info
data "aws_subnets" "default-subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}

#Creating a load balancer
resource "aws_lb" "CliXX-LB" {
  name = "ClixxAppLB"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default-subnets.ids
  security_groups = [aws_security_group.alb-sg.id]
}

# Defining a listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.CliXX-LB.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }

  }
}


# Creating a security group for the listener
resource "aws_security_group" "alb-sg" {
  name = "Clixx_LB_SG"
  # Allow inbound HTTP requests
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
# Creating a target group
resource "aws_lb_target_group" "ClixxTFTG" {
  name = "Clixx-TF-TG"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default-vpc.id

  health_check {
    path = "/index.html"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

# Creating a listener rule 
resource "aws_lb_listener_rule" "lb_listner_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    path_pattern {
      values = [ "*" ]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ClixxTFTG.arn
  }
}
output "alb_dns_name" {
  value = aws_lb.CliXX-LB.dns_name
  description = "The domain name of the load balancer"
}