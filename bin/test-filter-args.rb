#!/usr/bin/env ruby

$PROG = File.basename($0)
$LOAD_PATH << File.expand_path('lib')

require 'blank_empty_nil_filters'
require 'awesome_print'
require 'fileutils'
require 'optparse'
require 'pry-byebug'

$opts = ARGV.getopts('hinv')
$verobse     = $opts['v']
$norun       = $opts['n']
$interactive = $opts['i']
$help        = $opts['h'] || ARGV.detect { |arg| %w[--help help].include?(arg) }

def error(msg)
  warn(msg)
  exit -1
end

data = [
         :lev1, ' ', '', nil, :ok1,
         [:lev2a, ' ', '', nil, :ok2],
         ' ', '', :ok1b,
         [:lev2b, ' ', '', nil, :ok2b,
           [:lev3, ' ', :ok3, '', nil],
           nil],
         :ok1c
      ]

def ignore_stderr
  old_stderr = $stderr
  $stderr = File.open('/dev/null', 'wt')
  yield
  $stderr.close
ensure
  $stderr = old_stderr
end

def capture_stdout(filepath)
  old_stdout = $stdout
  File.open(filepath, 'wt') do |file|
    $stdout = file
    yield
  end
ensure
  $stdout = old_stdout
end

def diff_files(file1, file2)
  diff_cmd = "diff -y #{file1} #{file2}"
  puts "$ " + diff_cmd
  puts `#{diff_cmd}`
  puts ''
end

def is_okay?(msg)
  msg = msg.dup + "? [yN] "
  loop do
    $stderr.print msg
    ans = $stdin.gets&.chomp
    case ans
    when NilClass    then error "Quitting!"
    when /yes|ye|y/i then return true
    when /no|n/i, '' then return false
    end
  rescue Interrupt
    error "Interrupted!"
  end
end

ref_dir = 'test/ref'
out_dir = 'test/out'
diff_dir = 'test/diff'

['test', ref_dir, out_dir, diff_dir].each do |dir|
  unless Dir.exist?(dir)
    $stderr.print "Creating #{dir}: "
    ok = Dir.mkdir(dir)
    warn(ok ? 'ok' : 'uh-oh!')
  end
end

orig_output_filepath = 'test/out/test-original-output.txt'
capture_stdout(orig_output_filepath) do
  puts 'original:'
  ignore_stderr { puts data.ai(plain: true) }
end

diffs = 0
%i[no_empty_values no_blank_values no_nil_values].each do |filter|
  [
    [nil, 0], [nil, 1], [nil, 2], [nil, 3],
    [0, nil], [0,   1], [0,   2], [0,   3],
    [1, nil], [1,   1], [1,   2], [1,   3],
    [2, nil], [2,   1], [2,   2], [2,   3]
  ].each do |start, depth|
    test_name = "#{filter}(#{start || 'nil'},#{depth || 'nil'})"
    $stderr.printf "Testing #{test_name} .. "
    filename = "#{$PROG}_#{test_name.gsub(/[(,)]/, '_')}output.txt"
    out_file_path  = File.join(out_dir, filename)
    ref_file_path  = File.join(ref_dir, filename)
    diff_file_path = File.join(diff_dir, filename)
    capture_stdout(out_file_path) do
      puts "#{test_name}:"
      new_data = data.send(filter.to_sym, start, depth)
      ignore_stderr { puts new_data.ai(plain: true) }
    end
    FileUtils.touch(ref_file_path) unless File.exist?(ref_file_path)
    if FileUtils.compare_file(ref_file_path, out_file_path)
      warn "ok"
      FileUtils.rm out_file_path
    else
      diffs += 1
      warn "different! see #{diff_file_path}"
      capture_stdout(diff_file_path) do
        if File.size?(ref_file_path)
          puts 'Diffs between reference output and test filtered data:'
          diff_files(ref_file_path, out_file_path)
        end
        puts 'Diffs between original data and test filtered data:'
        diff_files(orig_output_filepath, out_file_path)
        if File.size?(ref_file_path)
          puts 'Diffs between original data and reference filtered data:'
          diff_files(orig_output_filepath, ref_file_path)
        end
      end
      if $interactive
        puts IO.read(diff_file_path)
        if is_okay?('Are the changes okay? ')
          FileUtils.rm ref_file_path if File.exist?(ref_file_path)
          FileUtils.mv out_file_path, ref_file_path
          FileUtils.rm diff_file_path
          warn "Ref copy updated"
        end
      end
    end
  end
end
if diffs > 0
  puts "There were #{diffs} differences!"
  puts "The output files are stored in test/out"
  puts "The reference output files are stored in test/ref"
  puts "and the difference listings are in test/diff"
  puts "Please review the difference listings; if the changes are acceptable,"
  puts "then please move the corresponding output file from test/out into"
  puts "test/ref.  If the changes are not acceptable, then please fix the bug!"
end
warn 'done'
exit
