class MoodleGiftParser::Question
  @comment = nil
  @category = nil

  @title = nil
  @markup = nil
  @content = nil
  @options = nil

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

  def comment; @comment end
  def category; @category end

  def title; @title end
  def markup; @markup end
  def content; @content end
  def options; @options end

  def comment=(input) @comment = input end
  def category=(input) @category = input end

  def title=(input) @title = input end
  def markup=(input) @markup = input end
  def content=(input) @content = input end
  def options=(input) @options = input end
end