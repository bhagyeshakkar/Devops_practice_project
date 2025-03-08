# main.tf

# Specify the provider (AWS in this case)
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Define the EC2 instance resource
resource "aws_instance" "my_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with the latest Ubuntu AMI ID (for us-east-1)
  instance_type = "t2.micro"               # Use a micro instance type (eligible for free tier)

  # Security group to allow SSH access
  security_group = aws_security_group.sg.id

  # Key name to associate an existing SSH key for accessing the instance (Optional)
  key_name = "your-ssh-key-name"  # Replace with your actual SSH key name

  tags = {
    Name = "MyTerraformVM"
  }

  # Block device mappings (optional, can customize storage)
  root_block_device {
    volume_size = 8  # Size in GB
    volume_type = "gp2"
  }

  # Ensure the instance is created with public IP (Optional)
  associate_public_ip_address = true
}

# Define a security group to allow SSH access to the EC2 instance
resource "aws_security_group" "sg" {
  name_prefix = "allow_ssh_"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs, restrict for production environments
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the public IP of the EC2 instance after creation
output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
