# frozen_string_literal: true

require "json"
require "uri"
require "simpleidn"
require "parallel"

module Ayashige
  module Sources
    class WebAnalyzer < Source
      BASE_URL = "https://wa-com.com"
      TLDS = %w(com net org info us bid biz cat club download life live ltd men pro review shop stream tech today trade win world xyz).freeze
      LIMIT = 5_000

      def store_newly_registered_domains
        date = latest_indexed_date

        Parallel.each(TLDS) do |tld|
          index = 1
          while index < LIMIT
            page = get_page(date, tld, index)
            records = get_records_from_doc(page)
            break if records.empty?

            records.each { |record| store record }
            index += 1
          end
        end
      end

      def get_page(date, tld, index)
        url = "#{BASE_URL}/#{date}/new-created-domains/#{tld}/p/#{index}"
        res = HTTP.get(url)
        html2doc(res.body.to_s)
      end

      def get_links_from_doc(doc)
        pages = doc.css("#form1 > div.container.mt30 > div:nth-child(1) > div.col-lg-12.col-md-12.col-sm-12.col-xs-12.nopadding.mt10 > span")
        pages.map do |page|
          link = page.at_css("a")
          link ? link.get("href") : nil
        end.compact
      end

      def get_records_from_doc(doc)
        rows = doc.css("#tblListDomain > tbody > tr")
        rows.map do |row|
          cols = row.css("td")
          domain_name = cols[0].at_css("a > span > span").text
          updated = cols[1].at_css("span").text

          Record.new(
            domain_name: SimpleIDN.to_ascii(domain_name),
            updated: updated
          )
        end
      end

      def latest_indexed_date
        @latest_indexed_date ||= [].tap do |out|
          res = HTTP.get(BASE_URL)
          doc = html2doc(res.body.to_s)
          break unless doc

          time = doc.css("#form1 > div.container.mt30 > div:nth-child(3) > div:nth-child(2) > table > tbody > tr:nth-child(1) > td > div > span:nth-child(1) > span.date > time")
          out << time.text
        end.first
      end
    end
  end
end
