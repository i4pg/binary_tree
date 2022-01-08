# A binary tree node
class Node
  attr_accessor :left, :right, :data

  attr_reader
  def initialize(data, left = nil, right = nil)
    @data = data
    @left = left
    @right = right
  end
end

class Tree
  attr_accessor :root, :array

  def initialize(array)
    @root = nil
    @array = array
    build_tree
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def build_tree(array = @array, start = 0, last = array.sort.uniq.length - 1)
    array = array.sort.uniq
    return if start > last

    mid = (start + last) / 2
    node = Node.new(array[mid])
    node.left = build_tree(array, start, mid - 1)
    node.right = build_tree(array, mid + 1, last)
    @root = node
  end

  def insert(value, node = @root)
    return nil if value == node.data

    if value < node.data
      node.left.nil? ? node.left = Node.new(value) : insert(value, node.left)
    else
      node.right.nil? ? node.right = Node.new(value) : insert(value, node.right)
    end
    find(value)
  end

  def delete(value)
    two_nodes = lambda { |val|
      return val if val.left.nil?

      two_nodes.call(val.left)
    }
    val = find(value)
    root = find_root(value)
    if val.right.nil? && val.left.nil?
      if root.data < val.data
        root.right = nil
      else
        root.left = nil
      end
    elsif val.right.nil? || val.left.nil?
      if val.right.nil?
        root.left = val.left
      elsif val.left.nil?
        root.right = val.right
      end
    else
      val.data = two_nodes.call(val.right).data
      val.right.left = nil
    end
  end

  def level_order_iteration(node = @root, arr = [node.data], queue = [node], &blk)
    until queue.empty?
      curr = queue.shift
      (queue << curr.left) && (arr << curr.left.data) unless curr.left.nil?
      (queue << curr.right) && (arr << curr.right.data) unless curr.right.nil?
    end
    block_given(arr, &blk)
  end

  def level_order_recursion(node = @root, queue = [node], arr = [node.data], &blk)
    curr = queue.shift
    return if node.nil? || curr.nil?

    (queue << curr.left) && (arr << curr.left.data) unless curr.left.nil?
    (queue << curr.right) && (arr << curr.right.data) unless curr.right.nil?
    level_order_recursion(curr, queue, arr)
    block_given(arr, &blk)
  end

  def preorder(node = @root, arr = [], &blk)
    return if node.nil?

    arr << node.data
    preorder(node.left, arr)
    preorder(node.right, arr)
    block_given(arr, &blk)
  end

  def inorder(node = @root, arr = [], &blk)
    return if node.nil?

    inorder(node.left, arr)
    arr << node.data
    inorder(node.right, arr)
    block_given(arr, &blk)
  end

  def postorder(node = @root, arr = [], &blk)
    return if node.nil?

    postorder(node.left, arr)
    postorder(node.right, arr)
    arr << node.data
    block_given(arr, &blk)
  end

  def height(node = @root)
    node = find(node) if node.is_a? Integer
    return -1 if node.nil?

    left = 0
    right = 0
    left += 1 + height(node.left)
    right += 1 + height(node.right)
    left > right ? left : right
  end

  def depth(node, root = @root, depth = 0)
    node = find(node)

    return depth if node == root

    depth += 1
    if node.data < root.data
      depth(node.data, root.left, depth) unless root.left.nil?
    else
      depth(node.data, root.right, depth) unless root.right.nil?
    end
  end

  def balanced?(node = @root, balanced = [true])
    return if node.right.nil? && node.left.nil?

    left = height(node.left) + 1
    right = height(node.right) + 1
    balanced << false if right > left + 1 || left > right + 1

    balanced?(node.left, balanced) unless node.left.nil?
    balanced?(node.right, balanced) unless node.right.nil?
    balanced.last
  end

  def rebalance
    build_tree(level_order_recursion)
  end

  private

  def block_given(arr)
    if block_given?
      yielded_array = []
      arr.each do |node|
        yielded_array << yield(node)
      end
      yielded_array
    else
      arr
    end
  end

  def find(key, root = @root)
    return root if root.nil? || root.data == key

    if root.data > key
      find(key, root.left)
    else
      find(key, root.right)
    end
  end

  def find_root(key, root = @root)
    return root if root.nil? || root.left.nil? || root.right.nil?
    return root if root.left.data == key || root.right.data == key

    if root.data > key
      find_root(key, root.left)
    else
      find_root(key, root.right)
    end
  end
end

arr = (Array.new(15) { rand(1..100) })
bts = Tree.new(arr)
bts.pretty_print
p bts.balanced?
p bts.level_order_recursion
p bts.level_order_iteration
p bts.preorder
p bts.postorder
p bts.inorder
bts.insert(rand(100..200))
bts.insert(rand(100..200))
bts.insert(rand(100..200))
bts.pretty_print
p bts.balanced?
bts.rebalance
bts.pretty_print
p bts.balanced?
p bts.level_order_recursion
p bts.level_order_iteration
p bts.preorder
p bts.postorder
p bts.inorder
