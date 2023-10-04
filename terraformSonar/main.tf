module "sonarNetworking" {
  source = "./modules/vpc"
}

module "ec2Computing" {
  source = "./modules/ec2"
  subnet_ids = module.sonarNetworking.subnet_ids
}