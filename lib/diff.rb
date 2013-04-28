# encoding: UTF-8

require File.expand_path('../diff_file', __FILE__)
require "tempfile"

class Diff
  def initialize(path_1, path_2)
    @diff_file_1  = DiffFile.new(path_1)
    @diff_file_2  = DiffFile.new(path_2)
    # Зарание мы не знаем как изменились файлы, по этому хранение
    # изменений будет организовано в файле, в противном случаее мы
    # можем выйти за ограничения на RAM.
    @file_changes = Tempfile.new('changes')
  end

  def compare
    {
      :deleted => process(@diff_file_1, @diff_file_2),
      :added   => process(@diff_file_2, @diff_file_1)
    }
  end

  private

  def reset
    @diff_file_1.reset!
    @diff_file_2.reset!
    @file_changes = Tempfile.new('changes')
  end

  # Возвращает путь до файла в котором содержаться
  # строки подвергшиеся изменения
  def process(diff_file_1, diff_file_2)
    reset

    while diff_file_1.can_read?
      # Считываем ограничение число строк в файле и
      # получаем эти строки в виде множества.
      diff_file_1.read!
      set_lines_1 = diff_file_1.set_lines

      while diff_file_2.can_read?
        diff_file_2.read!
        set_lines_2 = diff_file_2.set_lines

        # Находим пересечение, которое будет являться
        # общими строками в файле
        intersection = set_lines_1 & set_lines_2
        # Удаляем общие строки, оставшиеся означают
        # отсутсвие во втором файле
        set_lines_1.subtract(intersection)
        set_lines_2.clear
      end

      # Добавляем отсутсвующие строки в общий файл
      add_file_changes(set_lines_1.to_a)
      # Очищаем что бы мы могли считать новую часть файла в RAM
      set_lines_1.clear
      # Сбрасываем что мы могли перечитать второй файл по новой
      diff_file_2.reset!
    end

    @file_changes.rewind
    @file_changes
  end

  def add_file_changes(lines)
    return if lines.empty?
    data = lines.join("\n") + "\n"
    @file_changes.write(data)
  end
end