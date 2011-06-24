name :product
depends [:product_category]

read_method :ooor
write_method :ooor

before do
  puts "before"
end

from_iterator do
  [1,2,3,4]
end

after do
  puts "after"
end