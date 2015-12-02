require 'set'
require 'pp'
require 'tree'

word_file = "/usr/share/dict/words"

@start, @finish = ARGV

raise "#{@start} and #{@finish} must be the same length" if @start.length != @finish.length
length = @start.length

@words = Set.new(File.readlines(word_file).select { |word| word.length == length + 1 }.map(&:chomp).map(&:downcase))

raise "Either #{@start} or #{@finish} is not in the dictionary" unless @words.include?(@start) && @words.include?(@finish)

LETTERS = ('a'..'z').to_a.freeze

def generate_permutations(word, pos)
  word = word.dup
  original = word[pos]
  (LETTERS - [original]).map do |letter|
    word[pos] = letter
    next if !@words.include?(word)
    @words.delete(word)
    word.dup
  end.compact
end

def nearby_words(word)
  n_words = []
  0.upto(word.length - 1).each do |pos|
    n_words.concat generate_permutations(word, pos)
  end
  n_words
end

def process_queue(queue)
  new_queue = []
  queue.each do |word_node|
    return word_node if word_node.name == @finish
    @visited << word_node.name
    nearish = nearby_words(word_node.name).to_a
    nearish.each do |near|
      near_node = Tree::TreeNode.new(near)
      word_node << near_node
      new_queue << near_node
    end
  end
  raise "Can't find path" if new_queue.length == 0
  process_queue(new_queue)
end

@visited = Set.new

queue = []
queue << Tree::TreeNode.new(@start)

res = process_queue(queue)

ancestry = []
ancestry << res.name

until res.isRoot?
  res = res.parent
  ancestry.unshift(res.name)
end
puts ancestry.join(' -> ')
