# frozen_string_literal: true

module Ayashige
  module Jobs
    class WhoisDS < Job
      def initialize
        @source = Ayashige::Sources::WhoisDS.new
      end
    end
  end
end
