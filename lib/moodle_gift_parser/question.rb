class MoodleGiftParser::Question
  attr_accessor :comment
  attr_accessor :category
  attr_accessor :title
  attr_accessor :markup
  attr_accessor :content
  attr_accessor :options

  def initialize(question = nil)
    if question && question.is_a?(MoodleGiftParser::Question)
      self.comment = question.comment
      self.category = question.category
      self.title = question.title
      self.markup = question.markup
      self.content = question.content
      self.options = question.options
    end
  end

  def to_gift
    output = ''
    #FIXME Multiline comment?
    output << "// #{comment}\n" if comment
    output << "$CATEGORY: #{category}\n" if category
    output << "::#{title}::" if title
    output << "[#{markup}]" if markup
    output << escape_chars(content) + "{"
    output << options + "}"
    return output
  end

  private
  def escape_chars(string)
    escaped = string.tr("\r\n", '')
    escaped.gsub!('\\', '\\\\\\') # \ -> \\
    '~#={}'.split('').each { |c| escaped.gsub!(c, '\\'+c) }
    return escaped
  end
end