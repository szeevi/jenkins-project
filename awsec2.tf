provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "terraform_demo" {
  ami                    = "ami-0eba005a3e64054e1"
  instance_type          = "t3.micro"
  availability_zone      = "us-east-1c"
  vpc_security_group_ids = ["sg-00ef03cc35ddaa39c"]
  
  # שינוי השם לפי מה שקיים אצלך ב-AWS Console
  key_name               = "newkey" 

  tags = {
    Name = "TerraformOS"
  }
}

output "instance_ip" {
  value = aws_instance.terraform_demo.public_ip
}
