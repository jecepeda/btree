# typed: true
# frozen_string_literal: true

require "test_helper"

class BtreeTest < Minitest::Test
  def test_we_can_find_the_node
    btree = Btree::Btree.new(
      root_node: Btree::Node.new(
        keys: [3],
        children: [
          Btree::Node.new(
            keys: [2],
            children: [
              Btree::Node.new(keys: [1], children: [], is_leaf: true),
              Btree::Node.new(keys: [2], children: [], is_leaf: true)
            ]
          ),
          Btree::Node.new(
            keys: [10],
            children: [
              Btree::Node.new(keys: [3], children: [], is_leaf: true),
              Btree::Node.new(keys: [10, 15], children: [], is_leaf: true)
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

  def test_we_insert_nodes_into_btree
    btree = Btree::Btree.new

    1.upto(7) do |i|
      assert btree.insert i
    end
    assert_equal(
      { keys: [3, 5],
        children: [
          { keys: [2],
            children: [
              { keys: [1], children: [], is_leaf: true },
              { keys: [2], children: [], is_leaf: true }
            ] },
          { keys: [4],
            children: [
              { keys: [3], children: [], is_leaf: true },
              { keys: [4], children: [], is_leaf: true }
            ] },
          { keys: [6],
            children: [
              { keys: [5], children: [], is_leaf: true },
              { keys: [6, 7], children: [], is_leaf: true }
            ] }
        ] },
      btree.to_h
    )
  end

  def test_we_insert_nodes_into_btree_different_max_degree
    btree = Btree::Btree.new(max_degree: 5)

    1.upto(16) do |i|
      assert btree.insert i
    end

    assert_equal(
      {
        keys: [7],
        children: [
          {
            keys: [3, 5],
            children: [
              { keys: [1, 2], children: [], is_leaf: true },
              { keys: [3, 4], children: [], is_leaf: true },
              { keys: [5, 6], children: [], is_leaf: true }
            ]
          },
          {
            keys: [9, 11, 13],
            children: [
              { keys: [7, 8], children: [], is_leaf: true },
              { keys: [9, 10], children: [], is_leaf: true },
              { keys: [11, 12], children: [], is_leaf: true },
              { keys: [13, 14, 15, 16], children: [], is_leaf: true }
            ]
          }
        ]
      },
      btree.to_h
    )
  end
end
