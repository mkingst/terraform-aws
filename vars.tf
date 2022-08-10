variable "awsprops" {
    default = {
    region = "eu-west-1"
    ami = "ami-0a24fb6cfa6ebe011"
    itype = "t2.micro"
    publicip = true
    secgroupname = "NGINX-Sec-Group"
  }
}
