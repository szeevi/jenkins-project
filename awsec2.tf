provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "terraform_demo" {
  ami                    = "ami-0eba005a3e64054e1"
  instance_type          = "t3.micro"
  availability_zone      = "us-east-1c"
  vpc_security_group_ids = ["sg-00ef03cc35ddaa39c"]
  
  # חשוב: שנה את זה לשם של ה-Key Pair שלך ב-AWS כדי שתוכל להתחבר ב-SSH
  key_name               = "my-aws-key" 

  tags = {
    Name = "TerraformOS"
  }
}

# ה-Output שה-Jenkinsfile מחפש
output "instance_ip" {
  value = aws_instance.terraform_demo.public_ip
}
