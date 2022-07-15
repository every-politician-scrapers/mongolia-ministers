#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    decorator UnspanAllTables
    # decorator WikidataIdsDecorator::Links

    def member_container
      noko.xpath('//h2[contains(.,"Cabinet officers")][1]//following-sibling::ul[1]//li')
    end
  end

  class Member
    field :id do
    end

    field :name do
      last_holder.gsub(/\([^)]+\)/, '').tidy
    end

    field :positionID do
    end

    field :position do
      parts.first.gsub('Ministry', 'Minister')
    end

    field :startDate do
    end

    field :endDate do
    end

    private

    def parts
      noko.text.split(':', 2).map(&:tidy)
    end

    def last_holder
      parts[1].split(';').last.tidy
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
