require 'spec_helper'

feature 'Admin - Product Relation Management', js: true do

  before do
    Spree::RelationType.create(:name => "Related Products", :applies_to => "Spree::Product")
    @user = create(:experience_user)
    @experience1 = @user.experience
    @experience2 = create(:experience)
    @product1 = create :product
    @product1.add_experience! @experience1
    # TODO shoudl we allow them to relate to anyones product or only their own?
    @product2 = create :product
  end

  context 'as experience' do
    scenario 'should be able to add relations' do
      skip 'for some reason targetted_select2_search is not working properly'
      login_user @user
      visit spree.related_admin_product_path(@product1)
      targetted_select2_search @product2.name, from: 'Name or SKU'
      select2 @product2.name, from: 'Name or SKU'
      click_link 'Add'
      wait_for_ajax
      within '#products-table-wrapper' do
        page.should have_content(@product2.name)
      end
    end
  end

end
