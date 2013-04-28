require 'spec_helper'

describe DiffFile do
  let(:data) {
    [
      "/path/to/my_file_1",
      "/path/to/my_file_2",
      "/path/to/my_file_3"
    ].join("\n")
  }
  let(:file) {
    tempfile = Tempfile.new('file')
    tempfile.sync = true
    tempfile.write(data)
    tempfile
  }
  let(:path) {
    file.path
  }
  let(:diff_file) { DiffFile.new(path) }

  shared_context "файл считан полностью", :a => :b do
    before(:each) do
      while diff_file.can_read?
        diff_file.read!
        diff_file.set_lines.clear
      end
    end
  end

  describe "can_read?" do
    include_context "файл считан полностью"

    it "должен быть false" do
      diff_file.should_not be_can_read
    end
  end

  describe "reset!" do
    include_context "файл считан полностью"

    it "должен сбрасывать текущую позицию в файле" do
      diff_file.reset!
      diff_file.should be_can_read
    end

    it "должен сбрасывать множество строк" do
      diff_file.reset!
      diff_file.set_lines.should be_empty
    end
  end

  describe "read!" do

    it "должен считывать строки" do
      lines = []

      while diff_file.can_read?
        diff_file.read!
        lines += diff_file.set_lines.to_a
        diff_file.set_lines.clear
      end

      lines.join("\n").should == data
    end

    describe "set_lines" do
      let(:number_lines_to_read) { 1 }

      before(:each) do
        DiffFile.number_lines_to_read = number_lines_to_read
      end

      it "должен считывать строки" do
        diff_file.read!
        diff_file.set_lines.size.should == number_lines_to_read
      end

      context "множество строк заполнено макисмально" do
        before(:each) do
          diff_file.read!
        end

        it "не должен считывать новые строки" do
          expect {
            diff_file.read!
          }.to_not change(diff_file, :set_lines)
        end
      end

      context "множество строк заполнено не макисмально" do
        before(:each) do
          diff_file.read!
          line = diff_file.set_lines.to_a.sample
          diff_file.set_lines.delete(line)
        end

        it "должен считывать новые строки" do
          expect {
            diff_file.read!
          }.to change(diff_file, :set_lines)
        end
      end
    end
  end
end
