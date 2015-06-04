require 'digest/sha1'
require 'fileutils'
require 'tempfile'

module GitMedia
  module FilterClean

    def self.run!(filename="(unknown)", input=STDIN, output=STDOUT, info_output=true)

      if (filename==nil)
        filename="(unknown)"
      end

      begin
        sha = input.readpartial(42)
      rescue
        sha = ""
      end

      output.binmode

      if sha != nil && sha.length == 41 && sha.match(/^[0-9a-fA-F]+$/) != nil
        output.puts(sha)
        output.puts('Media clean detected hash '+sha[0,8]+'.. in '+filename)
      else

        hashfunc = Digest::SHA1.new
        start = Time.now

        tempfile = Tempfile.new('media', :binmode => true)

        # Write the first 42 bytes
        if sha != nil
	        hashfunc.update(sha)
        	tempfile.write(sha)
        end

        # read in buffered chunks of the data
        #  calculating the SHA and copying to a tempfile
        while data = input.read(4096)
          hashfunc.update(data)
          tempfile.write(data)
        end
        tempfile.close

        # calculate and print the SHA of the data
        output.print hx = hashfunc.hexdigest
        output.write("\n")

        # move the tempfile to our media buffer area
        media_file = GitMedia.media_path(hx)

        start = Time.now

        if !File.exists?(media_file)

          if GitMedia.filtersync?
            @push = GitMedia.get_push_transport

            if !@push.needs_push(hx)
              STDERR.puts('Skipping media upload: '+hx[0,8])
            else
              if @push.put_file(hx,tempfile.path)
                STDERR.puts('Uploaded media ' + hx[0,8] + '.. '+filename)
              else
                STDERR.puts('Failed to upload media ' + hx[0,8] + '.. '+filename)
                exit(1)
              end
            end
          end

          FileUtils.mv(tempfile.path, media_file)
          File.chmod(0640, media_file)

        end

        elapsed = Time.now - start

        if info_output
          STDERR.puts('Saved media : ' + hx + ' : ' + elapsed.to_s)
        end
      end
    end
  end
end
