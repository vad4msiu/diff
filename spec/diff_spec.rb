require 'spec_helper'

describe Diff do
  def file_to_changed(file)
    file.read.split("\n")
  end

  let(:file_1) {
    tempfile = Tempfile.new('file_1')
    tempfile.sync = true
    tempfile
  }
  let(:file_2) {
    tempfile = Tempfile.new('file_2')
    tempfile.sync = true
    tempfile
  }
  let(:path_1) { file_1.path }
  let(:path_2) { file_2.path }
  let(:diff)   { Diff.new(path_1, path_2) }
  let(:paths) {
    [
      "/path/to/my_file_1",
      "/path/to/my_file_2",
      "/path/to/my_file_3"
    ]
  }

  before(:each) do
    DiffFile.number_lines_to_read = 1
  end

  describe "run" do
    let(:result) { diff.compare }
    let(:added) { file_to_changed(result[:added]).sort }
    let(:deleted) { file_to_changed(result[:deleted]).sort }

    context "файлы пустые" do
      describe "added" do
        it "должены быть пустыми" do
          added.should be_empty
        end
      end

      describe "deleted" do
        it "должены быть пустыми" do
          deleted.should be_empty
        end
      end
    end

    context "файлы одинаковые" do
      before(:each) do
        data = paths.join("\n")

        file_1.write(data)
        file_2.write(data)
      end

      describe "added" do
        it "должены быть пустыми" do
          added.should be_empty
        end
      end

      describe "deleted" do
        it "должены быть пустыми" do
          deleted.should be_empty
        end
      end
    end

    context "добавлены новые пути" do
      let(:added_paths) {
        [
          "/path/to/new/my_file_1",
          "/path/to/new/my_file_2",
          "/path/to/new/my_file_3"
        ]
      }

      before(:each) do
        paths_1 = paths
        paths_2 = paths + added_paths

        data_1 = paths_1.join("\n")
        data_2 = paths_2.join("\n")

        file_1.write(data_1)
        file_2.write(data_2)
      end

      describe "added" do
        it "должены содержать добавленые пути" do
          added.should == added_paths.sort
        end
      end

      describe "deleted" do
        it "должены быть пустыми" do
          deleted.should be_empty
        end
      end
    end

    context "удалены старые пути" do
      let(:deleted_paths) {
        [
          "/path/to/old/my_file_1",
          "/path/to/old/my_file_2",
          "/path/to/old/my_file_3"
        ]
      }

      before(:each) do
        paths_1 = paths + deleted_paths
        paths_2 = paths

        data_1 = paths_1.join("\n")
        data_2 = paths_2.join("\n")

        file_1.write(data_1)
        file_2.write(data_2)
      end

      describe "added" do
        it "должены быть пустым" do
          added.should be_empty
        end
      end

      describe "deleted" do
        it "должены содержать удаленные пути" do
          deleted.should == deleted_paths.sort
        end
      end
    end
  end
end
