module MoodleGiftParser
  require 'logger'

  require 'moodle_gift_parser/parser'

  require 'moodle_gift_parser/question'
  require 'moodle_gift_parser/essay_question'
  require 'moodle_gift_parser/multiple_choice_question'

  require 'moodle_gift_parser/gift_error'
  require 'moodle_gift_parser/invalid_gift_format_error'

  class << self
    #http://stackoverflow.com/questions/11729456/how-do-i-log-correctly-inside-my-ruby-gem
    attr_writer :logger
    @logger = nil

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
        log.level = Logger::INFO
      end
      return @logger
    end
  end #class
end #module
