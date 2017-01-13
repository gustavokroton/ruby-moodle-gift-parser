module MoodleGiftParser::UtilHelper
  @@debug = false
  @@warn = true
  def debug(arg = nil)
    return unless @@debug
    message = block_given? ? yield : arg
    puts "DEBUG: #{message}"
  end

  def warn(arg = nil)
    return unless @@warn
    message = block_given? ? yield : arg
    puts "WARN: #{message}"
  end
end