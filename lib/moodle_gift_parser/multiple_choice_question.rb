class MoodleGiftParser::MultipleChoiceQuestion < MoodleGiftParser::Question
  include MoodleGiftParser::UtilHelper

  class Alternative
    attr_accessor :content
    attr_accessor :comment
    attr_accessor :correct
    attr_accessor :credit

    def initialize
      self.correct = false
      self.credit = 0
    end
  end

  WRONG_ALTERNATIVE_PREFIX = '~'
  CORRECT_ALTERNATIVE_PREFIX = '='
  ANSWER_COMMENT_PREFIX = '#'
  GENERIC_COMMENT_PREFIX = '####'

  ESCAPE_CHAR = "\\"

  VALID_ALTERNATIVE_PREFIXES = [
      CORRECT_ALTERNATIVE_PREFIX,
      WRONG_ALTERNATIVE_PREFIX
  ]

  attr_accessor :generic_comment
  attr_accessor :alternatives

  module State
    COMMENT = 'comment'
    ALTERNATIVE = 'alternative'
    GENERIC_COMMENT = 'generic_comment'
  end

  def self.can_convert?(question)
    return false unless question

    options = question.options.dup
    options.strip!

    #FIXME improve check
    return VALID_ALTERNATIVE_PREFIXES.include?(options[0])
  end

  def initialize(question = nil)
    super(question)
    if question
      options = question.options
      options.strip!

      first_type = options[0]
      unless VALID_ALTERNATIVE_PREFIXES.include?(first_type)
        raise MoodleGiftParser::InvalidGiftFormatError, "First char must be valid options: #{VALID_ALTERNATIVE_PREFIXES}"
      end

      alternatives = []
      self.generic_comment = ''

      current_alt = nil
      state = nil
      last_char = nil
      hashes = 0

      options.split('').each_with_index {|c,i|
        is_escaped = last_char == ESCAPE_CHAR
        was_comment = last_char == ANSWER_COMMENT_PREFIX
        last_char = c

        if VALID_ALTERNATIVE_PREFIXES.include?(c) && !is_escaped
          debug {"Hashes: '#{state}' -> '#{State::ALTERNATIVE}'"}
          current_alt              = Alternative.new
          if c == CORRECT_ALTERNATIVE_PREFIX
            current_alt.correct = true
            current_alt.credit = 100
          else
            current_alt.correct = false
            current_alt.credit = 0
          end
          current_alt.content = ''
          current_alt.comment = ''
          state = State::ALTERNATIVE
          hashes = 0

          alternatives << current_alt
          next
        end

        #TODO read credit
        #TODO read range

        if c == ANSWER_COMMENT_PREFIX && !is_escaped
          hashes+=1
          debug {"Found hash: count #{hashes}"}
          if hashes > 4
            raise MoodleGiftParser::InvalidGiftFormatError, "Invalid sequence of '#####' found."
          end

          next
        end

        if hashes == 1
          debug {"Hashes: '#{state}' -> '#{State::COMMENT}'"}
          if state == State::COMMENT
            raise MoodleGiftParser::InvalidGiftFormatError, "Two following comment sequences with '#' found."
          end

          state = State::COMMENT
          hashes = 0
        end

        if hashes == 4
          debug {"Hashes: '#{state}' -> '#{State::GENERIC_COMMENT}'"}
          unless self.generic_comment.empty?
            debug {"Empty: '#{self.generic_comment}'"}
            raise MoodleGiftParser::InvalidGiftFormatError, "Second '####' comment found."
          end
          state = State::GENERIC_COMMENT
          hashes = 0
        end

        if hashes > 0
          raise MoodleGiftParser::InvalidGiftFormatError, "Invalid sequence of '#' found."
        end


        case state
          when State::ALTERNATIVE
            current_alt.content << c
          when State::COMMENT
            current_alt.comment << c
          when State::GENERIC_COMMENT
            self.generic_comment << c
          else
            raise "Invalid internal type:#{state}"
        end
      }
      alternatives.each{|alt| alt.content && alt.content.strip!; alt.comment && alt.comment.strip!}
      self.generic_comment.strip!
      self.alternatives = alternatives
    end
  end
end