# typed: true
# frozen_string_literal: true

require_relative "btree/version"
require "sorbet-runtime"
require "debug"

##
# The Btree module provides functionalities for implementing B-tree data structures.
#
# B-trees are self-balancing tree data structures that maintain sorted data and allow for
# operations such as search, insertion, deletion in logarithmic time. They are particularly
# useful for storage systems that read and write large blocks of data.
#
module Btree
  class Error < StandardError; end

  # each node must have up to M elements
  class Node
    extend T::Sig

    sig { returns(T.nilable(Node)) }
    attr_accessor :parent

    sig { returns(T::Array[Integer]) }
    attr_accessor :keys

    sig { returns(T::Array[Node]) }
    attr_accessor :children

    sig do
      returns(T::Boolean)
    end
    attr_accessor :is_leaf

    sig { params(children: T::Array[Node], keys: T::Array[Integer], is_leaf: T::Boolean).void }
    def initialize(children: [], keys: [], is_leaf: false)
      @children = children
      @is_leaf = is_leaf
      @keys = keys

      @children.each do |children|
        children.parent = self
      end
    end

    sig { returns(T::Hash[Symbol, T.anything]) }
    def to_h
      {
        keys:,
        children: children.map(&:to_h),
        is_leaf:
      }
    end

    def root?
      parent.nil?
    end

    def leaf?
      is_leaf
    end
  end

  class Btree
    extend T::Sig

    sig { returns(T.nilable(Node)) }
    attr_reader :root_node

    sig { returns(Integer) }
    attr_reader :max_degree

    sig { params(root_node: T.nilable(Node), max_degree: Integer).void }
    def initialize(root_node: nil, max_degree: 3)
      @root_node = root_node
      @max_degree = max_degree
    end

    def to_h
      if root_node.nil?
        {}
      else
        root_node.to_h
      end
    end

    sig { params(k: Integer).returns(T.nilable(Node)) }
    def find(k)
      find_node(k, for_insert: false)
    end

    # we just store keys for now
    sig { params(value: Integer).returns(T::Boolean) }
    def insert(value)
      if @root_node.nil?
        @root_node = Node.new(keys: [value], is_leaf: true)
        return true
      end

      node = T.must(find_node(value, for_insert: true))

      # if the key is already inserted we return
      return false if node.keys.any? { |key| key == value }

      insert_in_leaf(node:, value:)
      return true if node.keys.size <= (max_degree - 1)

      # we need to split. we always insert the node
      # into the leaf for simplicity
      new_node = Node.new(is_leaf: true)
      split = node.keys.size / 2
      new_node.keys = T.must(node.keys.slice(split, node.keys.size))
      node.keys = T.must(node.keys.slice(0, split))
      new_value = T.must(new_node.keys.first)
      insert_in_parent(node:, new_node:, new_value:)

      true
    end

    private

    sig { params(node: Node, new_node: Node, new_value: Integer).void }
    def insert_in_parent(node:, new_node:, new_value:)
      if node.root?
        new_root = Node.new(keys: [new_value], children: [node, new_node])
        @root_node = new_root
        return
      end

      parent = T.must(node.parent)

      if parent.children.size < max_degree
        parent.children << new_node
        parent.keys << new_value
        new_node.parent = parent
        return
      end

      children = parent.children + [new_node]
      keys = parent.keys + [new_value]
      mid = keys.size / 2

      parent.children = T.must(children.slice(0, children.size / 2))
      parent.keys = T.must(keys.slice(0, mid))

      new_parent = Node.new(
        keys: T.must(keys.slice(mid + 1, keys.size)),
        children: T.must(children.slice(children.size / 2, children.size))
      )

      insert_in_parent(node: parent, new_node: new_parent, new_value: T.must(keys[mid]))
    end

    sig { params(node: Node, value: Integer).void }
    def insert_in_leaf(node:, value:)
      insert_at = node.keys.bsearch_index do |key|
        key >= value
      end

      if insert_at.nil?
        node.keys << value
      else
        node.keys.insert(T.must(insert_at), value)
      end
    end

    sig { params(k: Integer, for_insert: T::Boolean).returns(T.nilable(Node)) }
    def find_node(k, for_insert: false)
      return if root_node.nil?

      i = T.let(nil, T.nilable(Integer))
      node = T.must(root_node)
      while !node.leaf?
        key, min = node.keys.each_with_index.min
        i = (min if !key.nil? && k <= key)

        node =
          if i.nil?
            T.must(node.children.last)
          elsif k == key
            T.must(node.children[i + 1])
          else
            T.must(node.children[i])
          end
      end

      return node if for_insert

      node.keys.each do |key| # rubocop:disable Style/HashEachMethods
        return node if key == k
      end

      nil
    end
  end
end
