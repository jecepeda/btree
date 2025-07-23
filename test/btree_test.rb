# typed: true
# frozen_string_literal: true

require_relative "test_helper"

class BtreeTest < Minitest::Test
  def test_base_btree_to_h
    btree = Btree::Btree.new
    assert_equal({}, btree.to_h)
  end

  def test_string_keys_insertion_and_retrieval
    btree = Btree::Btree.new(key_type: String)
    strings = %w[apple banana cherry date elderberry fig grape]

    # Insert all strings
    strings.each do |str|
      assert btree.insert(str)

      # Verify all strings can be found
      assert_includes(btree.find(str)&.keys, str)
    end

    # Verify a non-existent string returns nil
    assert_nil btree.find("nonexistent")
  end

  def test_string_keys_with_special_characters
    btree = Btree::Btree.new(key_type: String)
    special_strings = ["a#b", "c&d", "e-f", "g_h", "i.j", "k!l", "m@n"]

    # Insert all special strings
    special_strings.each do |str|
      assert btree.insert(str)

      # Verify all special strings can be found
      assert_includes(btree.find(str)&.keys, str)
    end
  end

  def test_type_checking_enforcement
    btree = Btree::Btree.new(key_type: String)

    # String insertion should succeed
    assert btree.insert("test")

    # Integer insertion should raise TypeError
    assert_raises(TypeError) do
      btree.insert(42)
    end
  end

  def test_default_integer_enforcement
    btree = Btree::Btree.new

    # Integer insertions should succeed
    assert btree.insert(42)
    assert btree.insert(10)

    # String insertion should raise TypeError
    assert_raises(TypeError) do
      btree.insert("apple")
    end

    # Verify integers can be found
    assert_includes(btree.find(42)&.keys, 42)
    assert_includes(btree.find(10)&.keys, 10)
  end

  def test_mixed_types_with_nil_type_enforcement
    btree = Btree::Btree.new(key_type: nil)

    # Integer insertions should succeed
    assert btree.insert(42)
    assert btree.insert(10)

    # String insertion should raise TypeError because first insertion was Integer
    assert_raises(TypeError) do
      btree.insert("apple")
    end
  end

  def test_custom_comparable_objects
    # Define a custom comparable class
    person_class = Class.new do
      include Comparable
      attr_reader :name, :age

      def initialize(name, age)
        @name = name
        @age = age
      end

      def <=>(other)
        # Compare by age
        @age <=> other.age
      end

      def to_s
        "#{@name}(#{@age})"
      end
    end
    # Create some person objects
    alice = person_class.new("Alice", 30)
    bob = person_class.new("Bob", 25)
    charlie = person_class.new("Charlie", 35)
    david = person_class.new("David", 20)
    eve = person_class.new("Eve", 40)

    # Create a BTree for these custom objects
    btree = Btree::Btree.new(key_type: person_class)

    # Insert the objects
    assert btree.insert(alice)
    assert btree.insert(bob)
    assert btree.insert(charlie)
    assert btree.insert(david)
    assert btree.insert(eve)

    # Verify objects can be found
    assert_includes(btree.find(alice)&.keys, alice)
    assert_includes(btree.find(bob)&.keys, bob)
    assert_includes(btree.find(charlie)&.keys, charlie)
    assert_includes(btree.find(david)&.keys, david)
    assert_includes(btree.find(eve)&.keys, eve)

    # Create a new person with the same age as alice
    alice_twin = person_class.new("Alice Twin", 30)

    # Since comparison is by age, we should find alice when searching for alice_twin
    assert_includes(btree.find(alice_twin)&.keys, alice)
  end

  def test_we_can_find_the_node
    btree = Btree::Btree.new(
      root_node: Btree::Node.new(
        keys: [3],
        children: [
          Btree::Node.new(
            keys: [2],
            children: [
              Btree::Node.new(keys: [1], is_leaf: true),
              Btree::Node.new(keys: [2], is_leaf: true)
            ]
          ),
          Btree::Node.new(
            keys: [10],
            children: [
              Btree::Node.new(keys: [3], is_leaf: true),
              Btree::Node.new(keys: [10, 15], is_leaf: true)
            ]
          )
        ]
      )
    )

    assert_equal [10, 15], btree.find(10)&.keys
    assert_equal [1], btree.find(1)&.keys
    assert_equal [2], btree.find(2)&.keys
    assert_equal [3], btree.find(3)&.keys
    assert_nil btree.find(40)
  end

  def test_validate_node_keys_rejects_mixed_types
    # Create a tree with mixed types (Integer and String)
    mixed_tree = Btree::Node.new(
      keys: [3],
      children: [
        Btree::Node.new(
          keys: [2],
          children: [
            Btree::Node.new(keys: [1], is_leaf: true),
            Btree::Node.new(keys: ["2"], is_leaf: true) # String instead of Integer
          ]
        ),
        Btree::Node.new(keys: [10], is_leaf: true)
      ]
    )

    # This should raise TypeError when validate_node_keys runs during initialization
    error = assert_raises(TypeError) do
      Btree::Btree.new(root_node: mixed_tree)
    end

    assert_match(/Key .+ is not of type/, error.message)
  end

  def test_validate_node_keys_with_explicit_type
    # Create a tree with Integer keys
    int_tree = Btree::Node.new(
      keys: [3],
      children: [
        Btree::Node.new(keys: [1, 2], is_leaf: true),
        Btree::Node.new(keys: [4, 5], is_leaf: true)
      ]
    )

    # String type specified but tree has Integer keys
    error = assert_raises(TypeError) do
      Btree::Btree.new(root_node: int_tree, key_type: String)
    end

    assert_match(/Key .+ is not of type String/, error.message)

    # Correct key_type should work
    btree = Btree::Btree.new(root_node: int_tree, key_type: Integer)
    assert_equal Integer, btree.key_type
  end

  def test_exensive_find_node
    elements = (1..20).to_a
    [3, 4, 5, 6].each do |max_degree|
      btree = Btree::Btree.new(max_degree:)
      elements.map do |elem|
        btree.insert elem
      end

      elements.each do |elem|
        assert_includes(btree.find(elem)&.keys, elem)
      end
    end
  end

  def test_we_insert_nodes_into_btree
    btree = Btree::Btree.new

    1.upto(20) do |i|
      assert btree.insert i
    end
    assert_equal(
      { keys: [9],
        children: [
          { keys: [5],
            children: [
              { keys: [3],
                children: [
                  { keys: [2], children: [
                    { keys: [1], is_leaf: true },
                    { keys: [2], is_leaf: true }
                  ] },
                  { keys: [4],
                    children: [{ keys: [3], is_leaf: true },
                               { keys: [4], is_leaf: true }] }
                ] },
              { keys: [7],
                children: [
                  { keys: [6], children: [
                    { keys: [5], is_leaf: true },
                    { keys: [6], is_leaf: true }
                  ] },
                  { keys: [8], children: [
                    { keys: [7], is_leaf: true },
                    { keys: [8], is_leaf: true }
                  ] }
                ] }
            ] },
          { keys: [13], children: [
            { keys: [11],
              children: [
                { keys: [10],
                  children: [
                    { keys: [9], is_leaf: true },
                    { keys: [10], is_leaf: true }
                  ] },
                { keys: [12], children: [
                  { keys: [11], is_leaf: true },
                  { keys: [12], is_leaf: true }
                ] }
              ] },
            { keys: [15, 17],
              children: [
                { keys: [14],
                  children: [
                    { keys: [13], is_leaf: true },
                    { keys: [14], is_leaf: true }
                  ] },
                { keys: [16], children: [
                  { keys: [15], is_leaf: true },
                  { keys: [16], is_leaf: true }
                ] },
                { keys: [18, 19], children: [
                  { keys: [17], is_leaf: true },
                  { keys: [18], is_leaf: true },
                  { keys: [19, 20], is_leaf: true }
                ] }
              ] }
          ] }
        ] },
      btree.to_h
    )
  end

  def test_we_insert_nodes_random_order
    btree = Btree::Btree.new(max_degree: 5)
    elements = [15, 9, 1, 5, 4, 10, 17, 13, 2, 18, 12, 6, 3, 8, 16, 20, 14, 11, 19, 7]
    elements.each do |elem|
      btree.insert elem
    end
    assert_equal(
      { keys: [12],
        children: [
          { keys: [5, 7, 10],
            children: [
              { keys: [1, 2, 3, 4], is_leaf: true },
              { keys: [5, 6], is_leaf: true },
              { keys: [7, 8, 9], is_leaf: true },
              { keys: [10, 11], is_leaf: true }
            ] },
          { keys: [15, 17],
            children: [
              { keys: [12, 13, 14], is_leaf: true },
              { keys: [15, 16], is_leaf: true },
              { keys: [17, 18, 19, 20], is_leaf: true }
            ] }
        ] },
      btree.to_h
    )
  end

  def test_we_insert_nodes_into_btree_different_max_degree
    btree = Btree::Btree.new(max_degree: 5)

    1.upto(20) do |i|
      assert btree.insert i
    end

    assert_equal(
      { keys: [7, 13],
        children: [
          { keys: [3, 5],
            children: [
              { keys: [1, 2], is_leaf: true },
              { keys: [3, 4], is_leaf: true },
              { keys: [5, 6], is_leaf: true }
            ] },
          { keys: [9, 11], children: [
            { keys: [7, 8], is_leaf: true },
            { keys: [9, 10], is_leaf: true },
            { keys: [11, 12], is_leaf: true }
          ] },
          { keys: [15, 17], children: [
            { keys: [13, 14], is_leaf: true },
            { keys: [15, 16], is_leaf: true },
            { keys: [17, 18, 19, 20], is_leaf: true }
          ] }
        ] },
      btree.to_h
    )
  end

  def test_we_insert_nodes_into_btree_different_degree_four
    btree = Btree::Btree.new(max_degree: 4)

    1.upto(20) do |i|
      assert btree.insert i
    end

    assert_equal(
      { keys: [7, 13],
        children: [
          { keys: [3, 5],
            children: [
              { keys: [1, 2], is_leaf: true },
              { keys: [3, 4], is_leaf: true },
              { keys: [5, 6], is_leaf: true }
            ] },
          { keys: [9, 11], children: [
            { keys: [7, 8], is_leaf: true },
            { keys: [9, 10], is_leaf: true },
            { keys: [11, 12], is_leaf: true }
          ] },
          { keys: [15, 17, 19],
            children: [
              { keys: [13, 14], is_leaf: true },
              { keys: [15, 16], is_leaf: true },
              { keys: [17, 18], is_leaf: true },
              { keys: [19, 20], is_leaf: true }
            ] }
        ] },
      btree.to_h
    )
  end

  def test_we_delete_nodes_from_btree_size_three
    btree = Btree::Btree.new(max_degree: 3)
    elements = (1..50).to_a
    elements.each do |elem|
      btree.insert(elem)
    end
    shuffled = elements.shuffle
    shuffled.each do |elem|
      btree.delete(elem)
    end
    assert_equal({ keys: [], is_leaf: true }, btree.to_h, "keys used: #{shuffled}")
  end

  def test_we_delete_nodes_from_btree_size_four
    btree = Btree::Btree.new(max_degree: 4)
    elements = (1..50).to_a
    elements.each do |elem|
      btree.insert(elem)
    end
    shuffled = elements.shuffle
    shuffled.each do |elem|
      btree.delete(elem)
    end
    assert_equal({ keys: [], is_leaf: true }, btree.to_h, "keys used: #{shuffled}")
  end

  def test_we_delete_nodes_from_btree_size_five
    btree = Btree::Btree.new(max_degree: 5)
    elements = (1..50).to_a
    elements.each do |elem|
      btree.insert(elem)
    end
    shuffled = elements.shuffle
    shuffled.each do |elem|
      btree.delete(elem)
    end
    assert_equal({ keys: [], is_leaf: true }, btree.to_h, "keys used: #{shuffled}")
  end

  def test_we_delete_nodes_edge_case_first
    btree = Btree::Btree.new(max_degree: 5)
    elements = (1..50).to_a
    elements.each do |elem|
      btree.insert(elem)
    end
    shuffled = [
      12, 21, 3, 29, 8, 25, 4, 40, 36, 45, 5, 50, 32, 24, 39,
      16, 37, 7, 26, 10, 34, 14, 15, 18, 49, 27, 20, 43, 31, 19,
      13, 47, 22, 17, 30, 35, 38, 33, 6, 1, 41, 11, 44, 42,
      46, 9, 2, 23, 48, 28
    ]
    shuffled.each do |elem|
      btree.delete(elem)
    end
    assert_equal({ keys: [], is_leaf: true }, btree.to_h, "keys used: #{shuffled}")
  end

  def test_type_inference_from_first_insertion
    # Test with String as first insertion
    string_btree = Btree::Btree.new

    # First insertion is a String, should set the key_type to String
    assert string_btree.insert("apple")
    assert_equal String, string_btree.key_type
    assert string_btree.insert("banana")

    # Integer insertion should now raise TypeError
    assert_raises(TypeError) do
      string_btree.insert(42)
    end

    # Test with a Symbol as first insertion
    symbol_btree = Btree::Btree.new

    # First insertion is a Symbol, should set the key_type to Symbol
    assert symbol_btree.insert(:apple)
    assert_equal Symbol, symbol_btree.key_type
    assert symbol_btree.insert(:banana)

    # String insertion should now raise TypeError
    assert_raises(TypeError) do
      symbol_btree.insert("apple")
    end

    # Test with custom class as first insertion
    person_class = Class.new do
      include Comparable
      attr_reader :name, :age

      def initialize(name, age)
        @name = name
        @age = age
      end

      def <=>(other)
        @age <=> other.age
      end
    end

    custom_btree = Btree::Btree.new
    alice = person_class.new("Alice", 30)
    bob = person_class.new("Bob", 25)

    # First insertion sets the key_type to the custom class
    assert custom_btree.insert(alice)
    assert_equal person_class, custom_btree.key_type
    assert custom_btree.insert(bob)

    # String insertion should now raise TypeError
    assert_raises(TypeError) do
      custom_btree.insert("apple")
    end
  end

  def test_non_comparable_objects_raise_error
    # Test with a class that doesn't implement <=>
    non_comparable_class = Class.new do
      attr_reader :value

      def initialize(value)
        @value = value
      end

      # Explicitly delete <=> method if it's inherited
      undef :<=> if method_defined?(:<=>)
    end

    btree = Btree::Btree.new
    obj = non_comparable_class.new(42)

    # Should raise NonComparableObjectError
    error = assert_raises(Btree::NonComparableObjectError) do
      btree.insert(obj)
    end
    assert_match(/must implement the <=> operator/, error.message)

    # Test with a class that implements <=> but returns nil
    bad_comparable_class = Class.new do
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def <=>(_other)
        # Incorrectly returns nil for objects of the same class
        nil
      end
    end

    btree = Btree::Btree.new
    bad_obj = bad_comparable_class.new(42)

    # Should raise NonComparableObjectError
    error = assert_raises(Btree::NonComparableObjectError) do
      btree.insert(bad_obj)
    end
    assert_match(/returns nil from <=> operator/, error.message)
  end
end
