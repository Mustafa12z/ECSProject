module "vpc" {
  source = "./modules/vpc"
  private_subnet_cidr_block = var.private_subnet_cidr_block
  public_subnet_name = var.public_subnet_name
  sg_name = var.sg_name
  igw_name = var.igw_name
  subnet_cidr_block = var.subnet_cidr_block
  vpc_cidr_block = var.vpc_cidr_block
  private_subnet_name = var.private_subnet_name
  route_table_name = var.route_table_name
  vpc_name = var.vpc_name
}

module "alb" {
  source = "./modules/alb"
  tg_name = var.tg_name
  load_balancer_type = var.load_balancer_type
  elb-name = var.elb-name
  certificate_arn = var.certificate_arn
  public_subnetb_id = module.vpc.public_subnet_b_id
  public_subnet_id = module.vpc.public_subnet_a_id
  sg_id = module.vpc.security_group_id
  vpc_id = module.vpc.vpc_id
}

module "ecs" {
  source = "./modules/ecs"
  ecr-uri = var.ecr-uri
  ecs-fargate-name = var.ecs-fargate-name
  task-def-cpu = var.task-def-cpu
  ecs-cluster-name = var.ecs-cluster-name
  capacity_providers = var.capacity_providers
  private_subnet_id = module.vpc.private_subnet_a_id
  private_subnetb_id = module.vpc.private_subnet_b_id
  sg_id = module.vpc.security_group_id
  target_group_arn = module.alb.target_group_arn
}

module "route-53" {
  source = "./modules/route-53"
  subdomain_name = var.subdomain_name
  hosted_zone = var.hosted_zone
  dns_name = module.alb.alb_dns_name
}