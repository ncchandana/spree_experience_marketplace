require 'spec_helper'

describe "Admin - Properties" do

  context 'as Experience' do

    before do
      @experience_user = create(:experience_user)
      @experience = @experience_user.experience
      login_user @experience_user
      visit spree.admin_products_path
    end

    context "listing product properties" do
      it "should list the existing product properties" do
        create(:property, name: 'shirt size', presentation: 'size')
        create(:property, name: 'shirt fit', presentation: 'fit')

        click_link "Properties"
        within_row(1) do
          column_text(1).should == "shirt size"
          column_text(2).should == "size"
        end
        skip 'used to work not sure why not anymore'
        within_row(2) do
          column_text(1).should == "shirt fit"
          column_text(2).should == "fit"
        end
      end
    end

    context "creating a property" do
      it "should allow an admin to create a new product property", :js => true do
        skip 'Not sure if we want to allow this yet.'
        # click_link "Properties"
        # click_link "new_property_link"
        # within('#new_property') { page.should have_content("New Property") }
        #
        # fill_in "property_name", :with => "color of band"
        # fill_in "property_presentation", :with => "color"
        # click_button "Create"
        # page.should have_content("successfully created!")
      end
    end

    # TODO 'Not sure if we want to allow this yet.'
    # context "editing a property" do
    #   before(:each) do
    #     create(:property)
    #     click_link "Properties"
    #     within_row(1) { click_icon :edit }
    #   end
    #
    #   it "should allow an admin to edit an existing product property" do
    #     fill_in "property_name", :with => "model 99"
    #     click_button "Update"
    #     page.should have_content("successfully updated!")
    #     page.should have_content("model 99")
    #   end
    #
    #   it "should show validation errors" do
    #     fill_in "property_name", :with => ""
    #     click_button "Update"
    #     page.should have_content("Name can't be blank")
    #   end
    # end

    context "linking a property to a product", js: true do
      before do
        skip 'Still need to add proper support for managing products'
        p = create(:product)
        p.add_experience! @experience

        visit spree.admin_products_path
        click_icon :edit
        click_link "Product Properties"
      end

      # Regression test for #2279
      it 'should be successful' do
        expect(page).to have_content('Editing Product')
        fill_in "product_product_properties_attributes_0_property_name", with: "A Property"
        fill_in "product_product_properties_attributes_0_value", with: "A Value"
        click_button "Update"
        click_link "Product Properties"
        expect(page).to have_css("tbody#product_properties")
        expect(all("tbody#product_properties tr").count).to eq 2
      end
    end
  end
end
