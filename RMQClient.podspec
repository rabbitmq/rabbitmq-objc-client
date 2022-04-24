Pod::Spec.new do |s|
  s.name             = "RMQClient"
  s.version          = "0.12.0"
  s.summary          = "RabbitMQ client"
  s.description      = <<-DESC
  RabbitMQ client for Objective-C and Swift. Developed and supported by the
  RabbitMQ team.
                   DESC
  s.homepage         = "https://github.com/rabbitmq/rabbitmq-objc-client"
  s.license          = { type: "Apache 2.0", file: "LICENSE-APACHE2" }
  s.author           = { "RabbitMQ team" => "rabbitmq-users@googlegroups.com" }
  s.social_media_url = "https://twitter.com/rabbitmq"
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.11"
  s.source           = { git: "https://github.com/rabbitmq/rabbitmq-objc-client.git", tag: "v#{s.version}" }
  s.source_files     = "RMQClient", "RMQClient/**/*.{h,m}"
  s.dependency       "JKVValue", "~> 1.3"
  s.dependency       "CocoaAsyncSocket", "~> 7.6"

  s.info_plist = {
    'CFBundleIdentifier' => 'io.pivotal.RMQClient'
  }
end
