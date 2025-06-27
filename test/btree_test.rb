# typed: true
# frozen_string_literal: true

require "test_helper"

class BtreeTest < Minitest::Test
  def test_base_btree_to_h
    btree = Btree::Btree.new
    assert_equal({}, btree.to_h)
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
end
