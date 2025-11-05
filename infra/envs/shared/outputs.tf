output "service_account_emails" {
  description = "Emails of provisioned service accounts keyed by account ID."
  value       = { for k, v in module.service_accounts : k => v.email }
}
