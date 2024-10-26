module "vpc" {
  source = "./modules/vpc"
  public_subnet_name = "public-subnet-2"
  sg_name = "sg-ecs"
  igw_name = "ecs-igw"
  vpc_name = "ecs-vpc"
  private_subnet_name = "private-subnet"
  route_table_name = "public-route-table"
}

module "alb" {
  source = "./modules/alb"
  tg_name = "ecs-target"
  load_balancer_type = "application"
  elb-name = "ecs-elb"
  certificate_arn = "arn:aws:acm:eu-west-2:590184076390:certificate/390e1827-22af-4dd5-926c-fce3c2f134d5"
  public_subnetb_id = module.vpc.public_subnet_b_id
  public_subnet_id = module.vpc.public_subnet_a_id
  sg_id = module.vpc.security_group_id
  vpc_id = module.vpc.vpc_id
}

module "ecs" {
  source = "./modules/ecs"
  ecs-fargate-name = "fargate"
  task-def-cpu = 1024
  ecs-cluster-name = "threatcomposer-cluster"
  capacity_providers = ["FARGATE"]
  private_subnet_id = module.vpc.private_subnet_a_id
  private_subnetb_id = module.vpc.private_subnet_b_id
  sg_id = module.vpc.security_group_id
  target_group_arn = module.alb.target_group_arn
}

module "route-53" {
  source = "./modules/route-53"
  subdomain_name = "tm.teamcharlie.mustafamirreh.com"
  hosted_zone = "teamcharlie.mustafamirreh.com"
  dns_name = module.alb.alb_dns_name
}