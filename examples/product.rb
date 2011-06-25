name :product
depends [:product_category]

source_reader :ooor
target_writer :ooor

before do
  puts "before"
end

from_iterator do
  [1,2,3,4]
end

after do
  puts "after"
end

lines_actions do

  before do |from_line|
    puts "line before" + from_line.to_s
  end

  set_value(:col1) do |from_line|
    from_line * 10
  end

  after do |from_line|
    puts "line after" + from_line.to_s
  end

end