output vpc_arn {
  value = aws_vpc.custom_vpc.arn
}

output vpc_id {
  value = aws_vpc.custom_vpc.id
}

output private_subnet_ids {
  value = aws_subnet.private_subnet.*.id
}

output public_subnet_ids {
  value = aws_subnet.public_subnet.*.id
}

output control_plane_sg_security_group_id {
  value = aws_security_group.control_plane_sg.id
}

output data_plane_sg_security_group_id {
  value = aws_security_group.data_plane_sg.id
}

output public_subnet_security_group_id {
  value = aws_security_group.public_sg.id
}