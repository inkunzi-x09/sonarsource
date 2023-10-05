module "sonarNetworking" {
  source = "./modules/vpc"
}

module "ec2Computing" {
  source = "./modules/ec2"
  subnet_ids = module.sonarNetworking.subnet_ids
}

module "databaseRDS" {
  source = "./modules/databases"
  db_subnet_ids = module.sonarNetworking.db_subnet_ids
}

module "loadBalancing" {
  source = "./modules/alb"
  vpc_id = module.sonarNetworking.vpc_id
  pub_subnet_ids = module.sonarNetworking.pub_subnet_ids
}

module "containerECS" {
  source = "./modules/ecs"
  vpc_id = module.sonarNetworking.vpc_id
  private_subnet_ids = module.sonarNetworking.subnet_ids
  alb_id = module.loadBalancing.sonarAlbSG_id
  sonarAlbTg_id = module.loadBalancing.sonarAlbTg_id
  sonarLbListener = module.loadBalancing.sonarLbListener
}