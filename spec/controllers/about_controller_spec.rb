RSpec.describe AboutController, type: :controller do
    describe 'GET #index' do
        it 'renders index view' do
            get :index, locale: 'en'

            expect(response).to render_template :index
        end
    end
end
