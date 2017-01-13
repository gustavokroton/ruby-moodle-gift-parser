class MoodleGiftParser::EssayQuestion < MoodleGiftParser::Question
  def self.can_convert?(question)
    return false unless question

    options = question.options.dup
    options.strip!
    return options.empty?
  end

  def initialize(question = nil)
    super(question)
  end
end