describe Calabash::IOS::TextMixin do

  let(:device) do
    Class.new do
      include Calabash::IOS::TextMixin

      def uia_type_string(_) ; end
      def _tap(_) ; end
      def wait_for_keyboard; end

    end.new
  end

  it '#enter_text' do
    expect(device).to receive(:uia_type_string).with('text').and_return({})

    expect(device.enter_text('text')).to be_truthy
  end

  it '#enter_text_in' do
    expect(device).to receive(:_tap).with('query').and_return([])
    expect(device).to receive(:wait_for_keyboard).and_return true
    expect(device).to receive(:enter_text).with('text').and_return({})

    expect(device._enter_text_in('query', 'text')).to be_truthy
  end
end
