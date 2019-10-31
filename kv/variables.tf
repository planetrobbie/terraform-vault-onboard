variable "kv_path" {
  description = "key value secret engine mount point"
  default = "kv"
}

variable "secret_path" {
  description = "Secret path"
  default = "kv/demo"
}

variable "secret_data" {
  description = "Secret content"
  default = "{\"login\": \"anonymous\", \"password\": \"guest\", \"ttl\": \"20s\"}"
}