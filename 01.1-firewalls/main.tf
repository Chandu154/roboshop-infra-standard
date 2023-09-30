module "vpn_sg" {
  source = "../../terraform-aws-securitygroup"
    sg_name= "roboshop_vpn"
    sg_description = "allowing all ports from my home IP"
    project_name = var.project_name
    #sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_vpc.default.id
    common_tags = merge(
        var.common_tags,
    {
        Component= "VPN"
        Name= "roboshop-VPN"
    }
    )
}


module "mongodb_sg" {
  source = "../../terraform-aws-securitygroup"
    sg_name= "mongodb"
    sg_description = "allowing  traffic "
    project_name = var.project_name
    #sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = merge(
        var.common_tags,
        {
            Component = "MongoDB"
            Name= "MongoDB"
        }
    )
}

module "catalogue_sg" {
  source = "../../terraform-aws-securitygroup"
    sg_name= "catalogue"
    sg_description = "allowing  traffic from catalogue and user and VPN"
    project_name = var.project_name
    #sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = merge(
        var.common_tags,
        {
            Component = "catalogue"
            Name= "catalogue"
        }
    )
}


module "web_sg" {
  source = "../../terraform-aws-securitygroup"
    sg_name= "web"
    sg_description = "allowing  traffic"
    project_name = var.project_name
    #sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = merge(
        var.common_tags,
        {
            Component = "web"
            Name="web"
        }
    )
}


module "app_alb_sg" {
  source = "../../terraform-aws-securitygroup"
    sg_name= "App-ALB"
    sg_description = "allowing  traffic"
    project_name = var.project_name
    #sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = merge(
        var.common_tags,
        {
            Component = "App"
            Name = "App-ALB"
        }
    )
}


module "web_alb_sg" {
  source = "../../terraform-aws-securitygroup"
    sg_name= "Web-ALB"
    sg_description = "allowing  traffic"
    project_name = var.project_name
    #sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = merge(
        var.common_tags,
        {
            Component = "web"
            Name = "Web-ALB"
        }
    )
}

module "redis_sg" {
  source = "../../terraform-aws-securitygroup"
    sg_name= "redis"
    sg_description = "allowing  traffic"
    project_name = var.project_name
    #sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = merge(
        var.common_tags,
        {
            Component = "redis"
            Name = "redis"
        }
    )
}


module "user_sg" {
  source = "../../terraform-aws-securitygroup"
    sg_name= "user"
    sg_description = "allowing  traffic"
    project_name = var.project_name
    #sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = merge(
        var.common_tags,
        {
            Component = "user"
            Name = "user"
        }
    )
}


# making the rule to connect the only from our home ip
resource "aws_security_group_rule" "vpn" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.vpn_sg.security_group_id 
}


# This is allowing connections from  all catalogue instance to MangoDB
resource "aws_security_group_rule" "mongodb_catalogue" {
  type              = "ingress"
  description = "allowing port number 27017 from catalogue"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id = module.catalogue_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.mongodb_sg.security_group_id
}

# This is allowing traffic from VPN on port no 22  for trouble shooting 
resource "aws_security_group_rule" "mongodb_vpn" {
  type              = "ingress"
  description = "allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.mongodb_sg.security_group_id
}




resource "aws_security_group_rule" "mongodb_user" {
  type              = "ingress"
  description = "allowing port number 6379 from user"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  source_security_group_id = module.user_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.mongodb_sg.security_group_id
}

resource "aws_security_group_rule" "catalogue_vpn" {
  type              = "ingress"
  description = "allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.catalogue_sg.security_group_id
}


resource "aws_security_group_rule" "catalogue_app_alb" {
  type              = "ingress"
  description = "allowing port number 8080 from app alb"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.catalogue_sg.security_group_id
}



resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  description = "allowing port number 80 from vpn"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.app_alb_sg.security_group_id
}


resource "aws_security_group_rule" "app_alb_web" {
  type              = "ingress"
  description = "allowing port number 80 from web"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.app_alb_sg.security_group_id
}

resource "aws_security_group_rule" "web_vpn1" {
  type              = "ingress"
  description = "Allowing port number 80 from VPN"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_sg.security_group_id
}

resource "aws_security_group_rule" "web_vpn" {
  type              = "ingress"
  description = "allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_sg.security_group_id
}



resource "aws_security_group_rule" "web_web_alb" {
  type              = "ingress"
  description = "allowing port number 80 from web_alb"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_sg.security_group_id
}

resource "aws_security_group_rule" "web_alb_internet" {
  type              = "ingress"
  description = "allowing port number 80 from internet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_alb_sg.security_group_id
}

resource "aws_security_group_rule" "web_alb_internet_https" {
  type              = "ingress"
  description = "allowing port number 443 from internet"
  from_port         = 443
  to_port           = 443 
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.web_alb_sg.security_group_id
}

resource "aws_security_group_rule" "redis_user" {
  type              = "ingress"
  description = "allowing port number 6379 from user"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  source_security_group_id = module.user_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.redis_sg.security_group_id
}

resource "aws_security_group_rule" "redis_vpn" {
  type              = "ingress"
  description = "allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id =  module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.redis_sg.security_group_id
}


resource "aws_security_group_rule" "user_app_alb" {
  type              = "ingress"
  description = "allowing port number 8080 from APP ALB"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id =  module.app_alb_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.user_sg.security_group_id
}


resource "aws_security_group_rule" "user_vpn" {
  type              = "ingress"
  description = "allowing port number 22 from vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id =  module.vpn_sg.security_group_id
  #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = module.user_sg.security_group_id
}

