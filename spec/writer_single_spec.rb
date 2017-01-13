require 'spec_helper'

describe 'Write MultipleChoiceQuestion' do
  before(:example) do
    @question = MoodleGiftParser::MultipleChoiceQuestion.new
    @question.category = 'category'
    @question.content = 'Content'
    @question.markup = 'html'
    @question.alternatives
  end

  it 'should write without comment' do

  end

  it 'should write with comment' do

  end

  it 'should write with category' do

  end

  it 'should write without title and markup' do

  end
end