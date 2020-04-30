resource "aws_db_subnet_group" "tfdbsubnetgroup" {
name = "rdssg"
subnet_ids = [aws_subnet.tfprivatesubnet.id, aws_subnet.tfpublicsubnet.id, aws_subnet.tfpublicsubnet2.id] 

tags {
       Name = "rdssubnetgrp"
     }
}
