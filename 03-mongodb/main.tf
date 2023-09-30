# module "mongodb_sg" {
#   source = "../../terraform-aws-securitygroup"
#     sg_name= "mongodb"
#     sg_description = "allowing all traffic"
#     project_name = var.project_name
#     #sg_ingress_rules = var.sg_ingress_rules
#     vpc_id = data.aws_ssm_parameter.vpc_id.value
#     common_tags = var.common_tags
  
# }

## we are adding the rule to  the mongodb security group that is allowing traffic from vpn instance
# resource "aws_security_group_rule" "mongodb_vpn" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   source_security_group_id = data.aws_ssm_parameter.vpn_sg_id.value
#   #cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
#   #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
#   security_group_id = module.mongodb_sg.security_group_id
# }


module "mongodb_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.devops-ami.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [data.aws_ssm_parameter.mongodb_sg_id.value]
  #it should be in roboshop db subnet 
  subnet_id = local.db_subnet_id
  user_data = file("mongodb.sh")
  tags = merge (
    {
    Name= "MongoDB"
  },var.common_tags
  )
} 

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name 
  records = [
    {
      name    = "mongodb"
      type    = "A"
      ttl     = 1
      records = [
         module.mongodb_instance.private_ip
      ]
    }
  ] 
}


