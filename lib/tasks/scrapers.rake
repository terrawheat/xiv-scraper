require "rubygems"
require "nokogiri"
require "open-uri"

BaseURI = "http://xivdb.com/modules/content/content.php?lang=1&type=item&args="
CraftsIntoURI = "http://xivdb.com/modules/content/ajax/ajax.content.body.created.php?lang=1&id="
StartID = 4881
MaxID = 4881 # Seems to be ~14000
IDMap = {}
$CurrentDepth = 0
Separator = '--'

namespace :scrapers do
  desc "Scrapes all items from XIVDB"
  task scrape_items: :environment do

    for index in StartID..MaxID

      if IDMap.has_key?(index)
        next
      end

      build_item(index)

    end
  end

end

def build_item(index)
  # Retrieves the HTML for an item ID
  page = get_page(index)

  # Retrieves and outputs the name to the console
  item_name = page.css('.content-page-title').text
  logline = ''

  $CurrentDepth.times do
    logline << Separator
  end

  logline << " Building information for: <#{index}> #{item_name}"

  puts logline

  # Build an Item model for this item and decide whether we
  # need to build more items
  item = build_item_from_html(page)
  item.save

  IDMap[index] = true

  related_items = get_crafted_items(index)

  if related_items.length > 0
    $CurrentDepth += 1

    logline = ''

    $CurrentDepth.times do
      logline << Separator
    end
    logline << " Found related items!"
    puts logline

    related_items.each do |item|
      build_item(item)
      # TODO Insert related model
    end

    $CurrentDepth -= 1
  end
end

def get_page(id)
  uri = URI.parse("#{BaseURI}#{id}")

  Nokogiri::HTML(open(uri))
end

def get_crafted_items(index)
  url = "#{CraftsIntoURI}#{index}"
  uri = URI.parse(url)
  page = Nokogiri::HTML(open(uri))
  elements = page.css('.content-body-title a')
  items = []

  elements.each do |el|
    href = /item\/(\d+)/.match(el['href'])
    id = nil

    if (href && href.length > 1)
      items.push(href[1])
    end
  end

  items
end

def build_item_from_html(html)

  new_item_attributes = {
    name: html.css('.content-page-title').text
  }

  Item.new(new_item_attributes)
end
