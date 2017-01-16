class MoodleGiftParser::MultipleChoiceQuestion < MoodleGiftParser::Question
  ##
  # private module referencing internal state of parser
  module State
    COMMENT = 'comment'
    ALTERNATIVE = 'alternative'
    GENERIC_COMMENT = 'generic_comment'
  end

  class Alternative
    attr_accessor :content
    attr_accessor :comment
    attr_accessor :correct
    attr_accessor :credit

    def initialize
      self.correct = false
      self.credit = 0
    end

    def to_gift
      prefix = correct ? MoodleGiftParser::MultipleChoiceQuestion::CORRECT_ALTERNATIVE_PREFIX : MoodleGiftParser::MultipleChoiceQuestion::WRONG_ALTERNATIVE_PREFIX
      # TODO parse credit/range/credit
      result = "\t#{prefix}#{content}\n"
      result << "\t#{MoodleGiftParser::MultipleChoiceQuestion::ANSWER_COMMENT_PREFIX}#{comment}\n" if comment
      return result
    end

    def self.build_alternative(is_correct)
      current_alt = Alternative.new
      if is_correct
        current_alt.correct = true
        current_alt.credit  = 100
      else
        current_alt.correct = false
        current_alt.credit  = 0
      end
      current_alt.content = ''
      current_alt.comment = nil
      return current_alt
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


  def self.can_convert?(question)
    return false unless question

    options = question.options.dup
    options.strip!

    #FIXME improve check
    return VALID_ALTERNATIVE_PREFIXES.include?(options[0])
  end

  def self.parse_options(options)
    alternatives    = []
    generic_comment = ''

    current_alt = nil
    state       = nil
    last_char   = nil
    hashes      = 0

    options.split('').each do |c|
      is_escaped = last_char == ESCAPE_CHAR
      last_char  = c

      if VALID_ALTERNATIVE_PREFIXES.include?(c) && !is_escaped
        is_correct = c == CORRECT_ALTERNATIVE_PREFIX
        MoodleGiftParser.logger.debug { "Hashes: '#{state}' -> '#{State::ALTERNATIVE}'" }
        current_alt = Alternative.build_alternative(is_correct)
        state       = State::ALTERNATIVE
        hashes      = 0

        alternatives << current_alt
        next
      end

      #TODO read credit
      #TODO read range

      if !is_escaped && c == ANSWER_COMMENT_PREFIX
        hashes+=1
        MoodleGiftParser.logger.debug { "Found hash: count #{hashes}" }
        if hashes > 4
          raise MoodleGiftParser::InvalidGiftFormatError, "Invalid sequence of '#####' found."
        end

        next
      end

      if hashes == 1
        MoodleGiftParser.logger.debug { "Hashes: '#{state}' -> '#{State::COMMENT}'" }
        if state == State::COMMENT
          raise MoodleGiftParser::InvalidGiftFormatError, "Two following comment sequences with '#' found."
        end
        current_alt.comment = ''
        state  = State::COMMENT
        hashes = 0
      end

      if hashes == 4
        MoodleGiftParser.logger.debug { "Hashes: '#{state}' -> '#{State::GENERIC_COMMENT}'" }
        unless generic_comment.empty?
          raise MoodleGiftParser::InvalidGiftFormatError, "Second '####' comment found."
        end
        state  = State::GENERIC_COMMENT
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
          generic_comment << c
        else
          raise "Invalid internal type:#{state}"
      end
    end

    MoodleGiftParser.logger.debug {"Alternatives found: #{alternatives.length}. Generic_comment: '#{generic_comment}'."}

    return alternatives, generic_comment
  end

  def initialize(question = nil)
    super(question)
    if question
      options = question.options
      options.strip!

      first_type = options[0]
      unless VALID_ALTERNATIVE_PREFIXES.include?(first_type)
        raise MoodleGiftParser::InvalidGiftFormatError, "First char must be valid option: expected: #{VALID_ALTERNATIVE_PREFIXES}, got:'#{first_type}'"
      end

      alternatives, generic_comment = self.class.parse_options(options)

      # TODO unescape \ chars
      alternatives.each{|alt| alt.content && alt.content.strip!; alt.comment && alt.comment.strip!}
      self.generic_comment = generic_comment.strip
      self.alternatives = alternatives
    end
  end

  def to_gift
    self.options = "\n"
    alternatives.each do |alt|
      self.options << alt.to_gift
    end
    self.options << "\n\t#{GENERIC_COMMENT_PREFIX} #{self.generic_comment}" if self.generic_comment
    return super
  end


end