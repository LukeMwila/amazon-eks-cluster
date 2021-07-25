# Security group for data plane
resource "aws_security_group" "data_plane_sg" {
  name   = "k8s-data-plane-sg"
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "k8s-data-plane-sg"
  }
}

# Security group traffic rules
## Ingress rule
resource "aws_security_group_rule" "nodes" {
  description              = "Allow nodes to communicate with each other"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = flatten([var.private_subnet_cidr_blocks, var.public_subnet_cidr_blocks])
}

resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port   = 1025
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = flatten([var.private_subnet_cidr_blocks])
}

## Egress rule
resource "aws_security_group_rule" "node_outbound" {
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}