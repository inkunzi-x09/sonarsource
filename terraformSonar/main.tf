module "sonarNetworking" {
  source = "./modules/vpc"

  projectName = var.projectName
  availabilityZones = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
  vpcCidrBlock = var.vpcCidrBlock
  pubSubnetIps = [cidrsubnet(var.vpcCidrBlock, 8, 1), cidrsubnet(var.vpcCidrBlock, 8, 2), cidrsubnet(var.vpcCidrBlock, 8, 3)]
  privSubnetIps = [cidrsubnet(var.vpcCidrBlock, 8, 4), cidrsubnet(var.vpcCidrBlock, 8, 5), cidrsubnet(var.vpcCidrBlock, 8, 6)]
  dbSubnetIps = [cidrsubnet(var.vpcCidrBlock, 8, 7), cidrsubnet(var.vpcCidrBlock, 8, 8), cidrsubnet(var.vpcCidrBlock, 8, 9)]
}

module "ec2Computing" {
  source = "./modules/ec2"

  projectName = var.projectName
  vpc_id = module.sonarNetworking.vpc_id
  availabilityZones = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
  vpcCidrBlock = var.vpcCidrBlock
  pubSubnetIps = module.sonarNetworking.pub_subnet_ids
  privSubnetIps = module.sonarNetworking.priv_subnet_ids
  dbSubnetIps = module.sonarNetworking.db_subnet_ids
}

module "databaseRDS" {
  source = "./modules/databases"

  projectName = var.projectName
  vpc_id = module.sonarNetworking.vpc_id
  vpcCidrBlock = var.vpcCidrBlock
  db_subnet_ids = module.sonarNetworking.db_subnet_ids
}

/*module "loadBalancing" {
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
}*/