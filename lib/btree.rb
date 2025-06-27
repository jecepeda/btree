# typed: false
# frozen_string_literal: true

require_relative "btree/version"
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
    attr_accessor :keys, :children, :is_leaf, :parent

    def initialize(children: [], keys: [], is_leaf: false)
      @children = children
      @is_leaf = is_leaf
      @keys = keys

      set_parent
    end

    def set_parent
      @children.each do |children|
        children.parent = self
      end
    end

    def to_h
      if is_leaf
        {
          keys: keys,
          is_leaf: true
        }
      else
        {
          keys: keys,
          children: children.map(&:to_h)
        }
      end
    end

    def find_adjacent_node
      return [nil, nil, false] if parent.nil?

      idx = parent.children.find_index { |child| child == self }
      return [nil, nil, false] if idx.nil?

      if idx.zero?
        [parent.keys[idx], parent.children[idx + 1], false]
      else
        [parent.keys[idx - 1], parent.children[idx - 1], true]
      end
    end

    def entries
      keys.size
    end

    def root?
      parent.nil?
    end

    def leaf?
      is_leaf
    end
  end

  class Btree
    attr_reader :root_node, :max_degree

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

    def min_values(is_leaf)
      if is_leaf
        (max_degree - 1) / 2
      else
        max_degree / 2
      end
    end

    def find(k)
      find_node(k, for_insert: false)
    end

    # we just store keys for now
    def insert(value)
      if @root_node.nil?
        @root_node = Node.new(keys: [value], is_leaf: true)
        return true
      end

      node = find_node(value, for_insert: true)

      # if the key is already inserted we return
      return false if node.keys.any? { |key| key == value }

      insert_in_leaf(node:, value:)
      return true if node.keys.size < max_degree

      # we need to split. we always insert the node
      # into the leaf for simplicity
      new_node = Node.new(is_leaf: true)
      split = node.keys.size / 2
      new_node.keys = (node.keys.slice(split, node.keys.size))
      node.keys = (node.keys.slice(0, split))
      new_value = new_node.keys.first
      insert_in_parent(node:, new_node:, new_value:)

      true
    end

    def delete(value)
      node = find_node(value, for_insert: true)
      return if node.nil?

      delete_node(node, value, nil)
    end

    private

    def delete_node(node, value, pointer)
      node.keys.delete_at(node.keys.find_index(value) || node.keys.size)
      node.children.delete_at(node.children.find_index(pointer)) unless pointer.nil?
      if node.root? && node.children.size == 1
        @root_node = node.children.first
        @root_node.parent = nil
      elsif node.entries < min_values(node.leaf?)
        key_prime, node_prime, predecessor = node.find_adjacent_node

        entries = node.entries + (node_prime&.entries || 0)
        # coalesce nodes
        if entries < max_degree
          unless node_prime.nil?
            node, node_prime = node_prime, node unless predecessor
            if node.leaf?
              node_prime.keys += node.keys
            else
              node_prime.keys.append(key_prime)
              node_prime.keys += node.keys
              node_prime.children += node.children
              node_prime.set_parent
            end
          end
          delete_node(node.parent, key_prime, node) unless node.parent.nil?
        elsif predecessor && !node.leaf?
          last_child = node_prime.children.pop
          last_key = node_prime.keys.pop
          node.keys.prepend(key_prime)
          node.children.prepend(last_child)
          node.set_parent
          replace_parent(node, key_prime, last_key)
        elsif predecessor && node.leaf?
          last_key = node_prime.keys.pop
          node.keys.prepend(last_key)
          replace_parent(node, key_prime, last_key)
        elsif !node.leaf?
          first_child = node_prime.children.shift
          first_key = node_prime.keys.shift
          node.keys.append(key_prime)
          node.children.append(first_child)
          node.set_parent
          replace_parent(node, key_prime, first_key)
        elsif node.leaf?
          first_key = node_prime.keys.shift
          node.keys.append(first_key)
          replace_parent(node, key_prime, node_prime.keys.first)
        end
      end
    end

    def replace_parent(node, value, new_value)
      node.parent.keys.map! do |key|
        if key == value
          new_value
        else
          key
        end
      end
    end

    def insert_in_parent(node:, new_node:, new_value:)
      if node.root?
        new_root = Node.new(keys: [new_value], children: [node, new_node])
        @root_node = new_root
        return
      end

      parent = node.parent

      idx = parent.children.find_index(node)
      parent.children.insert(idx + 1, new_node)
      parent.keys.insert(idx, new_value)
      new_node.parent = parent

      return if parent.children.size <= max_degree

      children = parent.children
      keys = parent.keys

      mid_keys = (keys.size / 2).ceil
      mid_children = (children.size / 2.0).ceil

      parent.children = (children.slice(0, mid_children))
      parent.keys = (keys.slice(0, mid_keys))

      new_parent = Node.new(
        keys: keys.slice(mid_keys + 1, keys.size),
        children: children.slice(mid_children, children.size)
      )

      insert_in_parent(node: parent, new_node: new_parent, new_value: keys[mid_keys])
    end

    def insert_in_leaf(node:, value:)
      insert_at = node.keys.bsearch_index do |key|
        key >= value
      end

      if insert_at.nil?
        node.keys << value
      else
        node.keys.insert(insert_at, value)
      end
    end

    def find_node(k, for_insert: false)
      return if root_node.nil?

      i = nil
      node = root_node
      while !node.leaf?
        key = node.keys.filter do |key|
          key >= k
        end.min
        min = node.keys.find_index { |elem| elem == key }
        i = (min if !key.nil? && k <= key)

        node =
          if i.nil?
            node.children.last
          elsif k == key
            node.children[i + 1]
          else
            node.children[i]
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
