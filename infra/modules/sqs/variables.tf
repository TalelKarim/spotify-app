variable "queue_name" {
  type = string
}

variable "allow_eventbridge" {
  type    = bool
  default = false
}


variable "create_dlq" {
  type    = bool
  default = false
}

variable "max_receive_count" {
  type    = number
  default = 5
}
