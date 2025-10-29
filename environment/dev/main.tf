module "compute" {
  source = "../../modules/compute"

  project_name              = var.project_name
  environment               = var.environment
  instance_type             = var.instance_type
  desired_capacity          = var.desired_capacity
  min_capacity              = var.min_capacity
  max_capacity              = var.max_capacity
  public_subnet_1_id        = module.network.public_subnet_1_id
  public_subnet_2_id        = module.network.public_subnet_2_id
  alb_security_group_id     = module.security.alb_security_group_id
  ec2_security_group_id     = module.security.ec2_security_group_id
  ec2_iam_instance_profile  = module.security.ec2_instance_profile_name
  vpc_id                    = module.network.vpc_id
  ec2_key_pair_name         = var.ec2_key_pair_name
}

module "network" {
  source = "../../modules/network"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
}

module "database" {
  source = "../../modules/database"

  project_name             = var.project_name
  environment              = var.environment
  db_instance_class        = var.db_instance_class
  db_name                  = var.db_name
  db_username              = var.db_username
  db_password              = var.db_password
  db_storage_allocated     = var.db_storage_allocated
  private_subnet_1_id      = module.network.private_subnet_1_id
  private_subnet_2_id      = module.network.private_subnet_2_id
  rds_security_group_id    = module.security.rds_security_group_id
}

module "frontend" {
  source = "../../modules/frontend"

  project_name = var.project_name
  environment  = var.environment
  alb_dns_name = module.compute.alb_dns_name 
  depends_on = [ module.compute ]
}