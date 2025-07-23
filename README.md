# B+ Tree

A B+ Tree is a self-balancing tree data structure that keeps data sorted and allows searches, sequential access, insertions, and deletions in logarithmic time. It is a variant of the B-Tree where all records are stored at the leaf level of the tree; only keys are stored in interior nodes. This structure is well suited for storage systems that read and write large blocks of data, such as disks, because it minimizes disk I/O. It is commonly used in databases and filesystems.

## Installation

Since this gem is not published to RubyGems, you can install it directly from the Git repository:

```bash
# Add this to your Gemfile
gem 'btree', git: 'https://github.com/jecepeda/btree'
# Or using SSH
gem 'btree', git: 'git@github.com:jecepeda/btree.git'

# Then run
bundle install
```

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

### Multiple Types Support

The B+ Tree supports any Ruby object that implements the `<=>` operator, including:

- Strings
- Numbers
- Custom objects that include the `Comparable` module

The B+ Tree automatically infers the key type from the first insertion, ensuring type consistency throughout the tree. You can also explicitly specify the `key_type` parameter at initialization if needed.

#### String Keys Example

```ruby
# Create a B-Tree
btree = Btree::Btree.new

# First insertion sets the key type to String
btree.insert("apple")

# Additional string insertions work fine
btree.insert("banana")
btree.insert("cherry")
btree.insert("date")

# Search for strings
puts "Search for 'banana': #{!btree.find('banana').nil?}"  # => true
puts "Search for 'grape': #{!btree.find('grape').nil?}"    # => false
```

#### Type Enforcement

The B+ Tree enforces consistent types based on the first insertion or explicit specification:

```ruby
# Create a B-Tree
btree = Btree::Btree.new

# First insertion sets the key type to Integer
btree.insert(42)
btree.insert(10)

# This raises TypeError since first insertion was Integer
begin
  btree.insert("apple")
rescue TypeError => e
  puts "Error: #{e.message}"  # => Error: Key apple is not of type Integer
end
```

You can also explicitly enforce a specific type for all keys in the tree:

```ruby
# Create a B-Tree that only accepts String keys
btree = Btree::Btree.new(key_type: String)

# This works fine
btree.insert("apple")

# This raises TypeError
begin
  btree.insert(42)
rescue TypeError => e
  puts "Error: #{e.message}"  # => Error: Key 42 is not of type String
end
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
