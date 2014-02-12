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

      begin
        #Hack to retrieve line number in ExecJS errors
        #Based on this patch : https://github.com/josh/ruby-coffee-script/pull/21/
        wrapper = <<-WRAPPER
          (function(script, options) {
            try {
              return CoffeeScript.compile(script, options);
            } catch (err) {
              if (err instanceof SyntaxError && err.location) {
                throw new SyntaxError([options.filename, err.location.first_line + 1, err.location.first_column + 1].join(":") + ": " + err.message)
              } else {
                throw err;
              }
            }
          })
        WRAPPER
        ret = Source.context.call(wrapper, script, options)
      rescue Exception => e
        ret = {"js" => "console.error('#{e.message}');", "v3SourceMap" => '{"version" : 3, "sources" : []}'}
      end
      map_dir = Pathname.new(File.join(Dir.pwd, "public/source_maps"))
      map_dir.mkpath

      basename    = script_name.basename('.coffee')
      map_file    = map_dir.join "#{basename}.map"
      coffee_file = map_dir.join "#{basename}.coffee"

      # workaround for missing filename
      sm = ret["v3SourceMap"]
      source_map = JSON.load(sm)
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