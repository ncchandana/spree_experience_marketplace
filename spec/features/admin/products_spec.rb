require 'spec_helper'

describe 'Admin - Products', js: true do

  context 'as Admin' do

    xit 'should be able to change experience' do
      s1 = create(:experience)
      s2 = create(:experience)
      product = create :product
      product.add_experience! s1

      login_user create(:admin_user)
      visit spree.admin_product_path(product)

      select2 s2.name, from: 'experience'
      click_button 'Update'

      expect(page).to have_content("Product \"#{product.name}\" has been successfully updated!")
      expect(product.reload.experiences.first.id).to eql(s2.id)
    end

    it 'should display all products' do
      product1 = create :product
      product2 = create :product
      product2.add_experience! create(:experience)
      product2.reload
      product3 = create :product
      product3.add_experience! create(:experience)
      product3.reload

      login_user create(:admin_user)
      visit spree.admin_products_path

      page.should have_content(product1.name)
      page.should have_content(product2.name)
      page.should have_content(product3.name)
    end

  end

  context 'as experience' do

    before do
      @experience_user = create(:experience_user)
      @experience = @experience_user.experience
      login_user @experience_user
    end

    context "searching products works with only experiences in results" do
      it "should be able to search deleted products", :js => true do
        p1 = create(:product, :name => 'apache baseball cap', :deleted_at => "2011-01-06 18:21:13")
        p1.add_experience! @experience
        p2 = create(:product, :name => 'zomg shirt')
        p2.add_experience! @experience
        create(:product, :name => 'apache baseball bat', :deleted_at => "2011-01-06 18:21:13")
        create(:product, :name => 'zomg bat')

        visit spree.admin_products_path
        page.should have_content("zomg shirt")
        page.should_not have_content("apache baseball cap")
        page.should_not have_content("apache baseball bat")
        page.should_not have_content("zomg bat")
        check "Show Deleted"
        click_icon :search
        page.should have_content("zomg shirt")
        page.should have_content("apache baseball cap")
        page.should_not have_content("apache baseball bat")
        page.should_not have_content("zomg bat")
        uncheck "Show Deleted"
        click_icon :search
        page.should have_content("zomg shirt")
        page.should_not have_content("apache baseball cap")
        page.should_not have_content("apache baseball bat")
        page.should_not have_content("zomg bat")
      end

      it "should be able to search products by their properties with only experiences in results" do
        p1 = create(:product, :name => 'apache baseball cap', :sku => "A100")
        p1.add_experience! @experience
        create(:product, :name => 'apache baseball cap2', :sku => "B100")
        create(:product, :name => 'zomg shirt')
        p2 = create(:product, :name => 'zomg skirt')
        p2.add_experience! @experience


        visit spree.admin_products_path
        fill_in "q_name_cont", :with => "ap"
        click_icon :search
        page.should have_content("apache baseball cap")
        page.should_not have_content("apache baseball cap2")
        page.should_not have_content("zomg shirt")
        page.should_not have_content("zomg skirt")

        fill_in "q_variants_including_master_sku_cont", :with => "A1"
        click_icon :search
        page.should have_content("apache baseball cap")
        page.should_not have_content("apache baseball cap2")
        page.should_not have_content("zomg shirt")
        page.should_not have_content("zomg skirt")
      end
    end

    context "creating a new product from a prototype" do
      def build_option_type_with_values(name, values)
        ot = FactoryGirl.create(:option_type, :name => name)
        values.each do |val|
          ot.option_values.create(:name => val.downcase, :presentation => val)
        end
        ot
      end

      let(:prototype) do
        size = build_option_type_with_values("size", %w(Small Medium Large))
        create(:prototype, :name => "Size", :option_types => [ size ])
      end

      before do
        @option_type_prototype = prototype
        @property_prototype = create(:prototype, :name => "Random")
        @shipping_category = create(:shipping_category)
        visit spree.admin_products_path
        click_link "admin_new_product"
        within('#new_product') do
          page.should have_content("SKU")
        end
      end

      it "should allow an experience to create a new product and variants from a prototype" do
        fill_in "product_name", :with => "Baseball Cap"
        fill_in "product_sku", :with => "B100"
        fill_in "product_price", :with => "100"
        fill_in "product_available_on", :with => "2012/01/24"
        select "Size", :from => "Prototype"
        check "Large"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"
        page.should have_content("successfully created!")
        Spree::Product.last.variants.length.should == 1
        # Check experiences assigned properly
        expect(Spree::Product.last.experience_ids).to include(@experience.id)
      end

    end

    context "creating a new product" do

      before do
        @shipping_category = create(:shipping_category)
      end

      it "should allow an experience to create a new product" do
        visit spree.admin_products_path
        click_link "admin_new_product"
        within('#new_product') do
          page.should have_content("SKU")
        end
        fill_in "product_name", :with => "Baseball Cap"
        fill_in "product_sku", :with => "B100"
        fill_in "product_price", :with => "100"
        fill_in "product_available_on", :with => "2012/01/24"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"
        page.should have_content("successfully created!")
        click_button "Update"
        page.should have_content("successfully updated!")
        # Check experiences assigned properly
        expect(Spree::Product.last.experience_ids).to include(@experience.id)
      end

    end

    context "cloning a product" do
      it "should allow an experience to clone a product" do
        p = create(:product)
        p.add_experience! @experience

        visit spree.admin_products_path
        within_row(1) do
          click_icon :copy
        end

        page.should have_content("Product has been cloned")
        # Check experiences assigned properly
        expect(Spree::Product.last.experience_ids).to include(@experience.id)
      end

      context "cloning a deleted product" do
        it "should allow an experience to clone a deleted product" do
          p = create(:product, name: "apache baseball cap")
          p.add_experience! @experience

          visit spree.admin_products_path
          check "Show Deleted"
          click_button "Search"

          page.should have_content("apache baseball cap")

          within_row(1) do
            click_icon :copy
          end

          page.should have_content("Product has been cloned")
          # Check experiences assigned properly
          expect(Spree::Product.last.experience_ids).to include(@experience.id)
        end
      end
    end

    context 'updating a product' do
      let(:product) {
        p = create(:product)
        p.add_experience! @experience
        p.reload
      }

      it 'should not display experience selection' do
        visit spree.admin_product_path(product)
        page.should_not have_css('#product_experience_id')
      end
    end

  end

end
