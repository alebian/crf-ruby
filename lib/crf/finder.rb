require 'crf/repetitions_list'
require 'digest'
require 'find'
require 'ruby-progressbar'

module Crf
  #
  # This class finds the paths of all the repeated files inside the path passed as argument.
  # All files repeated have the same file_identifier and file_hash.
  #
  class Finder
    #
    # The original path provided and the list of files inside it are accessible from the outside.
    #
    attr_reader :path, :all_paths

    #
    # Creates the Finder object with a directory where it will look for duplicate files.
    # Path is the string representation of the absolute path of the directory.
    #
    def initialize(path)
      @path = path
    end

    #
    # Method that looks for the repeated files in the path specified when the object was created.
    #
    def search_repeated_files
      repetitions_list = Crf::RepetitionsList.new
      all_files(path).each do |file_path|
        repetitions_list.add(file_identifier(file_path), file_path)
      end
      return repetitions_list.repetitions if repetitions_list.repetitions.empty?
      confirm(repetitions_list)
    end

    private

    def all_files(path)
      paths = []
      Find.find(path) { |p| paths << p unless File.directory?(p) }
      paths
    end

    def file_identifier(path)
      File.size(path).to_s
    end

    def confirm(repetitions_list)
      confirmed_repetitions_list = Crf::RepetitionsList.new
      repetitions_list.repetitions.values.each do |repeated_array|
        repeated_array.each do |file_path|
          confirmed_repetitions_list.add(file_hash(file_path), file_path)
        end
      end
      confirmed_repetitions_list.repetitions
    end

    def file_hash(path)
      Digest::SHA256.file(path).hexdigest
    end
  end
end
