require 'spec_helper'

describe 'Write MultipleChoiceQuestion' do
  before(:example) do
    @question = MoodleGiftParser::MultipleChoiceQuestion.new
    @question.comment = 'comment'
    @question.category = 'category'
    @question.content = 'Content'
    @question.markup = 'html'
    @question.title = 'title'

    alt1 = MoodleGiftParser::MultipleChoiceQuestion::Alternative.build_alternative(true)
    alt1.content = 'Resposta correta'
    alt1.comment = 'Resposta está correta'

    alt2 = MoodleGiftParser::MultipleChoiceQuestion::Alternative.build_alternative(false)
    alt2.content = 'Resposta errada 2'

    alt3 = MoodleGiftParser::MultipleChoiceQuestion::Alternative.build_alternative(false)
    alt3.content = 'Resposta errada 3'

    @question.alternatives = [alt1, alt2, alt3]
  end

  it 'should write with default options' do
    gift = @question.to_gift
    expect(gift + "\n").to eq(<<EOF
// comment
$CATEGORY: category
::title::[html]Content{
\t=Resposta correta
\t#Resposta está correta
\t~Resposta errada 2
\t~Resposta errada 3
}
EOF
                           )
  end

  it 'should write without comment' do
    @question.comment = nil
    gift = @question.to_gift
    expect(gift + "\n").to eq(<<EOF
$CATEGORY: category
::title::[html]Content{
\t=Resposta correta
\t#Resposta está correta
\t~Resposta errada 2
\t~Resposta errada 3
}
EOF
)
  end


  it 'should write without category' do
    @question.category = nil
    gift = @question.to_gift
    expect(gift + "\n").to eq(<<EOF
// comment
::title::[html]Content{
\t=Resposta correta
\t#Resposta está correta
\t~Resposta errada 2
\t~Resposta errada 3
}
EOF
)
  end

  it 'should write without title and markup' do
    @question.title = nil
    @question.markup = nil
    gift = @question.to_gift
    expect(gift + "\n").to eq(<<EOF
// comment
$CATEGORY: category
Content{
\t=Resposta correta
\t#Resposta está correta
\t~Resposta errada 2
\t~Resposta errada 3
}
EOF
)
  end
end