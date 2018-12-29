Pod::Spec.new do |s|
  s.name             = "RMQClient"
  s.version          = "0.11.0-beta1"
  s.summary          = "RabbitMQ client"
  s.description      = <<-DESC
  RabbitMQ client for Objective-C and Swift. Developed and supported by the
  RabbitMQ team.
                   DESC
  s.homepage         = "https://github.com/rabbitmq/rabbitmq-objc-client"
  s.license          = "Mozilla Public License, Version 1.1 and Apache License, Version 2.0"
  s.author           = { "RabbitMQ team" => "rabbitmq-users@googlegroups.com" }
  s.social_media_url = "https://twitter.com/rabbitmq"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
  s.source           = { :git => "https://github.com/rabbitmq/rabbitmq-objc-client.git", :tag => "v#{s.version}" }
  s.source_files     = "RMQClient", "RMQClient/**/*.{h,m}"
  s.dependency       "JKVValue", "~> 1.3.3"
  s.dependency       "CocoaAsyncSocket", "~> 7.6.3"
end
