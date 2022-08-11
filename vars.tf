variable "awsprops" {
    default = {
    region = "eu-west-1"
    itype = "t2.xlarge"
    publicip = true
    secgroupname = "NGINX-Sec-Group"
  }
}
