require "prometheus/client/support/puma"

Prometheus::Client.configuration.logger = Rails.logger
Prometheus::Client.configuration.pid_provider = Prometheus::Client::Support::Puma.method(:worker_pid_provider)

require "yabeda/solid_queue"
Yabeda::SolidQueue.install!
