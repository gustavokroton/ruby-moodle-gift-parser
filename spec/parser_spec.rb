require 'rspec'

describe 'Quetion Parser' do
  before(:all) do
    @parser = MoodleGift::Parser.new
  end

  it 'should parse small question' do
    question = @parser.send(:build_question, 'Content{=correct ~wrong}', nil, nil)
    question.content.should be('Content')
  end

  it 'should parse small question with title' do
    question = @parser.send(:build_question, '::title::Question{=correct ~wrong}', nil, nil)
    question.title.should be('title')
  end

  it 'should parse small question with markup' do
  question = @parser.send(:build_question, '[html]Question{=correct ~wrong}', nil, nil)
  question.markup.should be('html')
  end
end