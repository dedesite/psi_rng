# based on this gist but adapt for Rack::Coffee 
# https://gist.github.com/naan/5096056
module CoffeeScript
  class SourceMapError < StandardError; end;

  class << self

    def compile script, options
      script_name = script
      script = script.read if script.respond_to?(:read)

      if options.key?(:no_wrap) and !options.key?(:bare)
        options[:bare] = options[:no_wrap]
      else
        options[:bare] = false
      end

      # adding source mapss option. (source maps option requires filename option.)
      options[:sourceMap] = true
      options[:filename]  = script_name.basename.to_s

      ret = Source.context.call("CoffeeScript.compile", script, options)

      map_dir = Pathname.new(File.join(Dir.pwd, "public/source_maps"))
      map_dir.mkpath

      basename    = script_name.basename('.coffee')
      map_file    = map_dir.join "#{basename}.map"
      coffee_file = map_dir.join "#{basename}.coffee"

      # workaround for missing filename
      source_map = JSON.load(ret["v3SourceMap"])
      source_map["sources"][0] = options[:filename]

      coffee_file.open('w') {|f| f.puts script }
      map_file.open('w')    {|f| f.puts source_map.to_json}

      comment = "\n/*\n//@ sourceMappingURL=/source_maps/#{map_file.basename}\n*/\n"
      return ret["js"] + comment

    end

  end
end

# I Just removes the .read call to compile
# in order to have the filename
module Rack
  class Coffee
    def brew(file)
      if cache_compile_dir
        cache_compile_dir.mkpath
        cache_file = cache_compile_dir + "#{file.mtime.to_i}_#{file.basename}"
        if cache_file.file?
          cache_file.read
        else
          brewed = compile(file)
          cache_file.open('w') {|f| f << brewed }
          brewed
        end
      else
        compile(file)
      end
    end
  end
end