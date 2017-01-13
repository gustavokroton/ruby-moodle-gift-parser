require 'spec_helper'

describe 'MultipleChoiceQuestion Parser' do
  before(:context) do
    @parser = MoodleGiftParser::Parser.new
  end

  after(:example) do
    expect(@question).to be_a(MoodleGiftParser::MultipleChoiceQuestion)
  end

  it 'should parse small question' do
    @question = @parser.send(:build_question, 'Question{=correct ~wrong}', nil, nil)
    expect(@question.content).to eq('Question')
  end

  it 'should parse small question with title' do
    @question = @parser.send(:build_question, '::title::Question{=correct ~wrong}', nil, nil)
    expect(@question.title).to eq('title')
    expect(@question.content).to eq('Question')
  end

  it 'should parse small question with markup' do
    @question = @parser.send(:build_question, '[html]Question{=correct ~wrong}', nil, nil)
    expect(@question.markup).to eq('html')
    expect(@question.content).to eq('Question')
  end

  it 'should parse small question with title and markup' do
    @question = @parser.send(:build_question, '::title::[html]Question{=correct ~wrong}', nil, nil)
    expect(@question.title).to eq('title')
    expect(@question.markup).to eq('html')
    expect(@question.content).to eq('Question')
  end

  it 'should parse multiline question with title and markup' do
    @question = @parser.send(:build_question, '
::title::[html]Question{
  =correct
  ~wrong
}', nil, nil)
    expect(@question.title).to eq('title')
    expect(@question.markup).to eq('html')
    expect(@question.content).to eq('Question')
  end

  it 'should parse multiline question with options' do
    @question = @parser.send(:build_question, 'Question{
  =correct
  #correct_comment
  ~wrong
  #wrong_comment
  ####generic_comment
}', nil, nil)

    expect(@question.content).to eq('Question')
    expect(@question.alternatives).to have(2).items
    expect(@question.alternatives[0].content).to eq('correct')
    expect(@question.alternatives[0].comment).to eq('correct_comment')
    expect(@question.alternatives[0].correct).to eq(true)
    expect(@question.alternatives[0].credit).to eq(100)
    expect(@question.alternatives[1].content).to eq('wrong')
    expect(@question.alternatives[1].comment).to eq('wrong_comment')
    expect(@question.alternatives[1].correct).to eq(false)
    expect(@question.alternatives[1].credit).to eq(0)
    expect(@question.generic_comment).to eq('generic_comment')
  end

  it 'should save category' do
    @question = @parser.send(:build_question, 'Question{=correct ~wrong}', 'category', nil)
    expect(@question.category).to eq('category')
  end

  it 'should save comment' do
    @question = @parser.send(:build_question, 'Question{=correct ~wrong}', nil, 'comment')
    expect(@question.comment).to eq('comment')
  end
end

describe 'MultipleChoiceQuestion Parser Exceptions' do
  before(:context) do
    @parser = MoodleGiftParser::Parser.new
  end

  it 'should fail on sequential comments' do
    expect {
      @question = @parser.send(:build_question, 'Question{
  =correct
  #correct_comment #ERROR
  ~wrong
  #wrong_comment
  ####generic_comment
}', nil, nil)
    }.to raise_error(MoodleGiftParser::InvalidGiftFormatError)
  end

  it 'should fail on multiple generic_comments' do
    expect {
      @question = @parser.send(:build_question, 'Question{
  =correct
  ####generic_comment
  ~wrong
  ####REPEATED
}', nil, nil)
    }.to raise_error(MoodleGiftParser::InvalidGiftFormatError)
  end

  it 'should fail on extreme sequences of hashes' do
    expect {
      @question = @parser.send(:build_question, 'Question{
  =correct
  ~wrong
  #####WRONG
}', nil, nil)
    }.to raise_error(MoodleGiftParser::InvalidGiftFormatError)
  end

  it 'should fail on weird sequences of hashes' do
    expect {
      @question = @parser.send(:build_question, 'Question{
  =correct
  ~wrong
  ###WRONG
}', nil, nil)
    }.to raise_error(MoodleGiftParser::InvalidGiftFormatError)
  end
end

describe 'EssayQuestion Parser' do
  before(:context) do
    @parser = MoodleGiftParser::Parser.new
  end

  after(:example) do
    expect(@question).to be_a(MoodleGiftParser::EssayQuestion)
  end

  it 'should parse small question' do
    @question = @parser.send(:build_question, 'EssayQuestion{}', nil, nil)
    expect(@question.content).to eq('EssayQuestion')
  end
end

