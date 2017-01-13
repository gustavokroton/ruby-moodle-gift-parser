class MoodleGiftParser::Writer
  @output = nil

  def initialize(output)
    self.output = output
  end

  def write(questions)
    questions.each do |q|
      q_gift = q.to_gift
      @output << q_gift + "\n\n"
    end
  end
end