# frozen_string_literal: true

require "faye/websocket"

module Ayashige
  module Sources
    class CertStream < Source
      BASE_URL = "wss://certstream.calidog.io"

      def store_newly_registered_domains(all_domains:, not_before:)
        return unless all_domains && not_before

        updated = Time.at(not_before).to_s
        all_domains.each do |domain|
          record = Record.new(domain_name: domain, updated: updated)
          store record
        end
      end

      def start
        EM.run do
          ws = Faye::WebSocket::Client.new(BASE_URL)

          ws.on :message do |event|
            message = JSON.parse(event.data)
            all_domains = message.dig("data", "leaf_cert", "all_domains")
            not_before = message.dig("data", "leaf_cert", "not_before")

            store_newly_registered_domains(all_domains: all_domains, not_before: not_before)
          end

          ws.on :close do |event|
            ws = nil
            start
          end
        end
      end
    end
  end
end
