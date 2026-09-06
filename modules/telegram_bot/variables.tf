variable "bot_name" {
  description = "Logical name of the bot, used for the Secret Manager secret id and labels (e.g. ahun)"
  type        = string
}

variable "bot_token" {
  description = "Bot token issued by @BotFather. Stored in Secret Manager and used to authenticate the telegram provider."
  type        = string
  sensitive   = true
}

variable "commands" {
  description = "Commands to register for the bot via setMyCommands. Leave empty to not manage commands."
  type = list(object({
    command     = string
    description = string
  }))
  default = []
}

variable "webhook_url" {
  description = "HTTPS URL to register as the bot webhook. Leave empty to keep the bot on long polling (getUpdates)."
  type        = string
  default     = ""
}

variable "webhook_allowed_updates" {
  description = "Update types the webhook should receive. Empty means all types."
  type        = list(string)
  default     = []
}
