module "vpc" {
  source              = "./modules/vpc"
}


module "iam" {
  source             = "./modules/iam" 

}



 module "s3" {
  source       = "./modules/s3"

} 

 module "eks" {
  source            = "./modules/eks"

} 
module "oidc" {
    
  source            = "./modules/oidc"
 
}