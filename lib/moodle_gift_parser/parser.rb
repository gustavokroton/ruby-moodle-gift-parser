module MoodleGiftParser
  #https://docs.moodle.org/32/en/GIFT_format

  class Parser
    CATEGORY_PREFIX = '$CATEGORY: '
    COMMENT_PREFIX  = '//'

    public
    def parse(content)
      questions = []

      category    = nil
      comment     = ''
      question    = ''
      empty_lines = 0
      content.each_line do |line|
        if line.strip.empty?
          empty_lines+=1
          if empty_lines >= 2 && !question.empty?
            MoodleGiftParser.logger.debug {"Question finished: '#{question}'"}
            questions << build_question_wrapped(question, category, comment)

            question = ''
            comment  = ''
          end
          next
        end

        if line.start_with?(CATEGORY_PREFIX)
          category = line[CATEGORY_PREFIX.length..-1].strip
          MoodleGiftParser.logger.debug {"Found category: '#{category}'"}
          next
        end

        if line.start_with?(COMMENT_PREFIX)
          #concat if multiline comment
          comment = comment + line[COMMENT_PREFIX.length..-1]
          MoodleGiftParser.logger.debug {"Found comment: '#{comment.strip}'"}
          next
        end

        question = question + line
      end

      if !question.empty?
        MoodleGiftParser.logger.debug {"Last question finished: '#{question}'"}
        questions << build_question_wrapped(question, category, comment)
      end

      return questions
    end

    private
    def build_question_wrapped(question, category, comment)
      begin
        return build_question(question, category, comment)
      rescue => e
        raise MoodleGiftParser::InvalidGiftFormatError, "Error parsing question:#{e.message}\nQuestion: '#{question}'", e.backtrace
      end
    end

    private
    def build_question(question_str, category, comment)
      question_text     = question_str.dup
      question          = MoodleGiftParser::Question.new()
      question.category = category
      question.comment  = comment

      question_text.gsub!(/^#{$/}/, '')

      title_regex = /^::(.+)::/
      title_match = question_text.match(title_regex)

      if title_match
        question.title = title_match[1]
        question_text.gsub!(title_regex, '')
      end

      markup_regex = /^\[(.+)\]/
      markup_match = question_text.match(markup_regex)
      if markup_match
        question.markup = markup_match[1]
        question_text.gsub!(markup_regex, '')
      end

      MoodleGiftParser.logger.debug {"after markup_match:#{question_text}"}

      #FIXME ignore escaped braces
      content_regex = /^([^{]+)\{/
      content_match = question_text.match(content_regex)
      if content_match
        question.content = content_match[1]
        question_text.gsub!(content_match[1], '')
      else
        raise MoodleGiftParser::InvalidGiftFormatError, "Missing question content before '{'."
      end

      MoodleGiftParser.logger.debug {"after content_match:#{question_text}"}

      #FIXME ignore escaped braces
      options_regex = /^(\{.*})/m
      options_match = question_text.match(options_regex)
      unless options_match
        raise MoodleGiftParser::InvalidGiftFormatError, "Missing options content '{...}'."
      end
      if options_match.length != 2
        raise MoodleGiftParser::InvalidGiftFormatError, "Multiple options content '{...}'."
      end

      question.options = options_match[1][1..-2]
      question_text.gsub!(options_regex, '')

      #FIXME get content after keys

      converted_question = convert_question(question)

      return converted_question
    end

    def convert_question(question)
      question_classes = [
          MoodleGiftParser::EssayQuestion,
          MoodleGiftParser::MultipleChoiceQuestion
      ]

      question_classes.each do |qclass|
        MoodleGiftParser.logger.debug {"Checking conversion for: #{qclass.name}"}
        if qclass.respond_to?(:can_convert?) && qclass.can_convert?(question)
          MoodleGiftParser.logger.debug {"Converting to #{qclass.name}"}
          return qclass.new(question)
        end
      end

      MoodleGiftParser.logger.warn {"No valid question type found for question: #{question}"}

      return question
    end
  end #class
end #module