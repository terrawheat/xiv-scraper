def jobs()
  jobs = [
    { name: 'Culinarian', abbreviation: 'CUL' },
    { name: 'Goldsmith', abbreviation: 'GSM' },
    { name: 'Armorer', abbreviation: 'ARM' },
    { name: 'Carpenter', abbreviation: 'CRP' },
    { name: 'Leatherworker', abbreviation: 'LTW' },
    { name: 'Weaver', abbreviation: 'WVR' },
    { name: 'Alchemist', abbreviation: 'ALC' },
    { name: 'Blacksmith', abbreviation: 'BSM' },
  ]

  jobs.each do |job|
    puts "Creating Job: #{job[:name]}"
    j = Job.new(job)
    j.save
  end

end
