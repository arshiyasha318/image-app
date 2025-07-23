output "vpc_id" {
  value = aws_vpc.k8svpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public-us-east-1a.id,
    aws_subnet.public-us-east-1b.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id
  ]
}

output "all_subnet_ids" {
  value = concat(
    [aws_subnet.public-us-east-1a.id, aws_subnet.public-us-east-1b.id],
    [aws_subnet.private-us-east-1a.id, aws_subnet.private-us-east-1b.id]
  )
}
