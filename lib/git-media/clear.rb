require 'git-media/status'

module GitMedia
  module Clear

    def self.run!
      @push = GitMedia.get_push_transport
      self.clear_local_cache
    end

    def self.clear_local_cache
      # find files in media buffer and delete all pushed files
      all_cache = GitMedia.all_cache
      unpushed_files = @push.get_unpushed(all_cache)
      pushed_files = all_cache - unpushed_files
      pushed_files.each do |sha|
        puts "Removing " + sha[0, 8]
        File.unlink(GitMedia.media_path(sha))
      end
    end

  end
end