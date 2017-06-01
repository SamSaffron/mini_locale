require 'yaml'
require 'optparse'

$filename = ARGV[0]

def usage
  puts "Usage: hlf FILENAME"
end

if !$filename || !File.exist?($filename)
  usage
  exit 1
end

class Hlf
  def initialize(hash)
    @hash = hash
    @print_every = 20
    @collapse_length = 3
  end

  def to_s
    dump(@hash)
  end

  protected

  def dump(hash, prefix=nil, line=0)
    cur = 0
    buffer = ""

    hash.each do |k,v|
      if Hash === v
        if v.length <= @collapse_length && v.values.all?{|vv| String === vv}
          v.each do |inner_key, inner_val|
            if (cur % @print_every) == 0
              buffer << "\n[#{prefix}]\n" if prefix
            end
            cur += 1
            buffer << "#{k}.#{inner_key}: #{inner_val}\n"
          end
        else
          buffer << dump(v, prefix ? "#{prefix}.#{k}" : k, line + cur)
        end

      else
        if (cur % @print_every) == 0
          buffer << "\n[#{prefix}]\n" if prefix
        end
        cur += 1
        v = "\n" + v.strip if v =~ /\n/
        buffer << "#{k}: #{v}\n"
      end
    end

    buffer
  end
end

puts Hlf.new(YAML.load_file($filename)).to_s
