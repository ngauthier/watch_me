#!/usr/bin/env ruby
def parse_command
  my_args = ARGV.clone
  my_args.slice!(0) if my_args[0] == '--'
  @files = []
  while my_args.size > 0
    arg = my_args.shift
    case arg
      when '-l'
        @lines = my_args.shift
      when '-r'
        @refresh = my_args.shift
      else
        @files.push arg
    end
  end
  
  @files ||= []
  @lines ||= 24
  @refresh ||= 4
  
  @lines = @lines.to_i
  @refresh = @refresh.to_i
  
  if @files.size <= 0
    raise "Need at least one file"
  end
  
  @lines_per_file = (@lines - 2 - @files.size) / @files.size
  
  min_height = 2 * @files.size + 2
  if @lines_per_file <= 0
    raise "Not enough height for that many files. For [#{@files.size}] files you need a height of at least [#{min_height}]"
  end
end

def build_command
  command = "watch -n #{@refresh.to_s} \""
  file_cmds = []
  @files.each do |filename|
    file_cmds.push "echo '=== #{filename} ===' && tail -n #{@lines_per_file.to_s} #{filename}" 
  end
  command += file_cmds.join(" && ")
  command += "\""
end

def main
  begin
    parse_command
  rescue => ex
    $stderr.write "Error: #{ex.to_s}\n"
    $stderr.write "Usage: watch_me.rb -l lines -r refresh file1 [file2 file3 ...]\n"
    $stderr.write "       lines: number of rows to use, a.k.a. height of console. Default 24.\n"
    $stderr.write "       refresh: refresh interval in seconds. Default 4\n"
    exit(1)
  end
  command = build_command
  exec command
end

main

