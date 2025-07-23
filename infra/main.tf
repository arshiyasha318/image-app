module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  availability_zones  = var.availability_zones
}


module "iam" {
  source             = "./modules/iam" 

}



 module "s3" {
  source       = "./modules/s3"
  bucket_name = var.s3_bucket_name

} 

 module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  eks_version       = var.eks_version

} 
module "oidc" {
    
  source            = "./modules/oidc"
 
}