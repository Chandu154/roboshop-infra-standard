
module "rabbitmq_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.devops-ami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.rabbitmq_sg_id.value]
  #it should be in roboshop db subnet 
  subnet_id = local.db_subnet_id
  user_data = file("rabbitmq.sh")
  tags = merge (
    {
    Name= "rabbitmq"
  },var.common_tags
  )
} 

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name 
  records = [
    {
      name    = "rabbitmq"
      type    = "A"
      ttl     = 1
      records = [
         module.rabbitmq_instance.private_ip
      ]
    }
  ] 
}


