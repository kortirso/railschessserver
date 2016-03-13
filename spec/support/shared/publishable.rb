shared_examples_for 'Publishable' do
    it 'should send message by PrivatePub' do
        expect(PrivatePub).to receive(:publish_to).with(path, kind_of(Hash))
        object
    end
end