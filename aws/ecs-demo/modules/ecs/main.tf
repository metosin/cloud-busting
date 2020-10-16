resource "aws_ecs_cluster" "main" {
  # Note: Just to try out use of remote state, doesn't actually make sense
  name = "${data.terraform_remote_state.network.outputs.vpc_id}-main"
}
