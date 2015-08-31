require "rubygems"
require "nokogiri"
require "open-uri"

# Constants
# URI for grabbing the main data for an item
BaseURI = "http://xivdb.com/modules/content/content.php?lang=1&type=item&args="

# Async path for grabbing crafting targets
CraftsIntoURI = "http://xivdb.com/modules/content/ajax/ajax.content.body.created.php?lang=1&id="

StartID = 1 # 4881 Rothlyt Oyster is test
MaxID = 100 # Seems to be ~14000

# Map to keep tracked of scraped IDs
IDMap = {}

# Global used to track how many separators to output
$CurrentDepth = 0
Separator = '--'

namespace :scrapers do
  desc "Scrapes all items from XIVDB"
  task scrape_items: :environment do

    for index in StartID..MaxID

      # If the item has already been scraped by a previously recursive
      # crafting scrape, skip it
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
  item = build_item_from_html(page, index)

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
    end

    $CurrentDepth -= 1
  end
end

# Retrieve the HTML for a single item
def get_page(id)
  uri = URI.parse("#{BaseURI}#{id}")

  Nokogiri::HTML(open(uri))
end

# Retrieve the craft into HTML
def get_additional_info(index)
  url = "#{CraftsIntoURI}#{index}"
  uri = URI.parse(url)
  Nokogiri::HTML(open(uri))
end

# Retrieves the item IDs of associated crafts
def get_crafted_items(index)
  page = get_additional_info(index)
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

# Takes the HTML from an items page and create a model
def build_item_from_html(html, index)

  new_item_attributes = {
    xiv_index: index,
    name: html.css('.content-page-title').text,
  }

  item = Item.new(new_item_attributes)

  additional_info = get_additional_info(index)

  job_data = html.css('#page-crafted span[style="display:inline-block;width:300px;"]').text
  matches = /.*Attempt Level:\s*(\d+)\s*(\w+)/.match(job_data)

  item.save

  if (matches)
    job_requirements = {
      level: matches[1],
    }
    jr = JobRequirement.new(job_requirements)
    jr.job = Job.find_by({ name: matches[2] })
    jr.item = item
    jr.save
  end

  item
end
