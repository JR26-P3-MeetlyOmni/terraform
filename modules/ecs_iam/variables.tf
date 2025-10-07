variable "name_prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "ecs_execution_role" {
  type = string
}

variable "ecs_task_role" {
  type = string
}

variable "execution_additional_policy_arns" {
  type    = list(string)
  default = []
}

variable "task_additional_policy_arns" {
  type    = list(string)
  default = []
}

