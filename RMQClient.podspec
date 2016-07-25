Pod::Spec.new do |s|
  s.name             = "RMQClient"
  s.version          = "0.9.0"
  s.summary          = "RabbitMQ client"
  s.description      = <<-DESC
  RabbitMQ client for iOS Objective-C and Swift. Developed and supported by the
  RabbitMQ team.
                   DESC
  s.homepage         = "https://github.com/rabbitmq/rabbitmq-objc-client"
  s.license          = "Mozilla Public License, Version 1.1 and Apache License, Version 2.0"
  s.author           = { "RabbitMQ team" => "info@rabbitmq.com" }
  s.social_media_url = "https://twitter.com/rabbitmq"
  s.platform         = :ios, "8.0"
  s.source           = { :git => "https://github.com/rabbitmq/rabbitmq-objc-client.git", :tag => "v#{s.version}" }
  s.source_files     = "RMQClient", "RMQClient/**/*.{h,m}"
  s.dependency       "JKVValue"
  s.dependency       "CocoaAsyncSocket", "~> 7.4"
end
