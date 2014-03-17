# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }
#
guard :shell, :all_on_start => false do
  #watch(/lib\/(.*).rb/) {|m| `ruby proofs/all.rb` }
  watch(/proofs\/(.*).rb/) {|m| `ruby #{m[0]}`}
end
