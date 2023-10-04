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
  pub_subnet_ids = module.sonarNetworking.pub_subnet_ids
}