module MoodleGift
  #https://docs.moodle.org/32/en/GIFT_format
  class Parser
    CATEGORY_PREFIX = '$CATEGORY: '
    COMMENT_PREFIX = '//'

    public
    def parse(content)
      questions = []

      category = nil
      comment = ''
      question = ''
      empty_lines = 0
      content.each_line do |line|
        if line.length == 0
          empty_lines+=1
          if empty_lines >= 2 && !question.empty?
            questions << build_question(question, category, comment)
            question = ''
            comment = ''
          end
          next
        end

        if line.start_with?(CATEGORY_PREFIX)
          category = line[CATEGORY_PREFIX.length..-1]
          next
        end

        if line.start_with?(COMMENT_PREFIX)
          #concat if multiline comment
          comment = comment + line[COMMENT_PREFIX.length..-1]
          next
        end

        question = question + line
      end

      return questions
    end

    private
    def build_question(question, category, comment)
      title_match = question.match(/^::(.+)::/)
      title = title_match[1] if title_match

      markup_match = question.match(/^\[([^\]]+)\]|::\[([^\]]+)\]/)
      markup = markup_match[1] if markup_match

    end
  end #class
end #module