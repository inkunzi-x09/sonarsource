module "sonarNetworking" {
  source = "./modules/vpc"
}

module "ec2Computing" {
  source = "./modules/ec2"
  subnet_ids = module.sonarNetworking.subnet_ids
}

module "databaseRDS" {
  source = "./modules/databases"
  subnet_ids = module.sonarNetworking.subnet_ids
}