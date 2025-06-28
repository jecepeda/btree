# B+ Tree

A B+ Tree is a self-balancing tree data structure that keeps data sorted and allows searches, sequential access, insertions, and deletions in logarithmic time. It is a variant of the B-Tree where all records are stored at the leaf level of the tree; only keys are stored in interior nodes. This structure is well suited for storage systems that read and write large blocks of data, such as disks, because it minimizes disk I/O. It is commonly used in databases and filesystems.

## Usage

You can use the B+ Tree as follows:

```ruby
require "btree"

# Create a new B-Tree with a specific degree.
# The degree determines the maximum number of keys/children per node.
btree = Btree::Btree.new(max_degree: 3)

# Insert some values
btree.insert(10)
btree.insert(20)
btree.insert(5)
btree.insert(6)
btree.insert(12)
btree.insert(30)
btree.insert(7)
btree.insert(17)

# The `find` method returns the leaf node containing the key.
# A return value of `nil` means the key was not found.
puts "Search for 6: #{!btree.find(6).nil?}"    # => true
puts "Search for 15: #{!btree.find(15).nil?}"  # => false

# Delete a value
btree.delete(17)
puts "Search for 17 after deletion: #{!btree.find(17).nil?}" # => false

# You can inspect the tree structure using `to_h`
puts "Tree structure:"
p btree.to_h
```

## Running the tests

To run the tests, you can use the following command:

```bash
bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jecepeda/btree.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
