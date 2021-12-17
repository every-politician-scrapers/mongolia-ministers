#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  # decorator WikidataIdsDecorator::Links

  field :ministers do
    member_entries.flat_map do |ul|
      mem = fragment(ul => Officeholder)
      mem.names.map { |name| { name: name, position: mem.position } }
    end
  end

  private

  def member_entries
    noko.xpath('//h2[contains(.,"Cabinet officers")][1]//following-sibling::ul[1]//li')
  end
end

class Officeholder < Scraped::HTML
  field :name do
    names
  end

  field :position do
    parts.first.gsub('Ministry', 'Minister')
  end

  def parts
    noko.text.split(':', 2).map(&:tidy)
  end

  def names
    parts.last.gsub(/\([^)]+\)/, '').split(';').map(&:tidy)
  end
end

url = 'https://en.wikipedia.org/wiki/Cabinet_of_Ukhnaagiin_Kh%C3%BCrels%C3%BCkh'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
