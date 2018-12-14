# frozen_string_literal: true

module Ayashige
  module Jobs
    class CertStream < Job
      def initialize
        @source = Ayashige::Sources::CertStream.new
      end

      def perform
        with_error_handling { @source.start }
      end
    end
  end
end
