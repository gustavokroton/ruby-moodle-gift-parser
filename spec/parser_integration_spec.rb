require 'spec_helper'

describe 'Parse file' do
  before(:context) do
    @parser = MoodleGiftParser::Parser.new
  end

  after(:example) do
    expect(@questions).to have(3).items

    q1 = @questions[0]
    expect(q1).to be_a(MoodleGiftParser::MultipleChoiceQuestion)
    expect(q1.category).to eq('$system$/Default/Example Category/Sub Category')
    expect(q1.title).to eq('2017.1-U4S1-Q01')
    expect(q1.markup).to eq('html')
    expect(q1.content).to eq('<p><span>Example 1</span></p>\n<p><span>Therefore\: </span></p>\n<p><span>Question\:</span></p>')
    expect(q1.alternatives).to have(5).items
    alt1 = q1.alternatives[0]
    expect(alt1.content).to eq('<p><span>First</span></p>')
    expect(alt1.correct).to eq(false)
    expect(alt1.comment).to eq(nil)
    alt3 = q1.alternatives[2]
    expect(alt3.content).to eq('<p><span>Correct.</span></p>')
    expect(alt3.correct).to eq(true)
    expect(alt3.comment).to eq('<p><span>Reason.</span></p>')

    q2 = @questions[1]
    expect(q2).to be_a(MoodleGiftParser::MultipleChoiceQuestion)
    expect(q2.category).to eq('$system$/Default/Example Category/Sub Category')

    q3 = @questions[2]
    expect(q3).to be_a(MoodleGiftParser::MultipleChoiceQuestion)
    expect(q3.category).to eq('$system$/Default/Example Category 2/Sub Category 2')
    expect(q3.generic_comment).to eq('<p>Generic comment!.</p>')
  end

  it 'should should parse file correctly' do
    path = File.expand_path '../example/example-gift-multiple-choice.gift', __FILE__
    File.open(path, 'r') do |file|
      @questions = @parser.parse(file)
    end
  end
end