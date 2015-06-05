module GitMedia
  module Transport
    class Base

      def pull(final_file, sha)
        to_file = GitMedia.media_path(sha)
        return get_file(sha, to_file)
      end

      def push(sha)
        from_file = GitMedia.media_path(sha)
        return put_file(sha, from_file)
      end


      ## OVERWRITE ##

      def exist?(file)
        false
      end

      def get_file(sha, to_file)
        false
      end

      def put_file(sha, to_file)
        false
      end

      def get_unpushed(files)
        media_buffer = GitMedia.get_media_buffer
        files.select do |f|
            path = File.join(media_buffer,f)
            if File.directory?(path)
                false
            else
                !exist?(f)
            end
        end
      end

      def needs_push(sha)
        return !exist?(sha)
      end


    end
  end
end
