


sensu_gem "mail" do
  version "~> 2.5.4"
end

handler_path = "/etc/sensu/handlers/mailer.rb"

cookbook_file handler_path do
  source "handlers/mailer.rb"
  mode 0755
end

sensu_snippet "mailer" do
  content(
    :mail_from => node["monitor"]["mail_from"],
    :delivery_method => node["monitor"]["delivery_method"],
    :smtp_address => node["monitor"]["smtp_address"],
    :smtp_port => node["monitor"]["smtp_port"],
    :smtp_domain => node["monitor"]["smtp_domain"],
    :smtp_username => node["monitor"]["smtp_username"],
    :smtp_password => node["monitor"]["smtp_password"],
    :smtp_authentication => node["monitor"]["smtp_authentication"],
    :smtp_enable_starttls_auto => node["monitor"]["smtp_enable_starttls_auto"]
  )
end

sensu_handler "mailer" do
  type "pipe"
  command "mailer.rb"
end