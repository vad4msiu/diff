# encoding: UTF-8

require "set"

# Класс отвечающий за чтение файла. Чтение происходит частями предустановленного
# размера. Считанные строки для одной части хранятся в структуре Set для быстрого поиска вхождений.
class DiffFile
  attr_reader :set_lines

  @@number_lines_to_read = 2_000_000

  def self.number_lines_to_read=(value)
    @@number_lines_to_read = value.to_i
  end

  def self.number_lines_to_read
    @@number_lines_to_read
  end

  def initialize(path)
    @file      = File.open(path)
    @set_lines = Set.new
  end

  def read!
    number_lines_to_add = @@number_lines_to_read - set_lines.size
    number_lines_to_add.times do
      break if @file.eof?

      line = @file.gets.chomp
      set_lines.add(line)
    end

    return @set_lines
  end

  def reset!
    @file.rewind
    @set_lines.clear
  end

  def can_read?
    !@file.eof?
  end
end
