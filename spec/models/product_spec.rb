# spec/models/product_spec.rb
require 'rails_helper'

RSpec.describe Product, type: :model do
  # Créer une organisation à utiliser dans tous les tests
  let(:organisation) { Organisation.create!(business_name: "Organisation Test") }
  
  let(:valid_attributes) do
    {
      name: "Produit test",
      description: "Description du produit test",
      organisation_id: organisation.id,
      prices_attributes: { "0" => { amount: 19.99 } }
    }
  end

  describe "validations" do
    it "est valide avec des attributs valides" do
      product = Product.new(valid_attributes)
      expect(product).to be_valid
    end
    
    it "n'est pas valide sans organisation" do
      product = Product.new(valid_attributes.merge(organisation_id: nil))
      expect(product).not_to be_valid
    end

    it "n'est pas valide sans nom" do
      product = Product.new(valid_attributes.merge(name: nil))
      expect(product).not_to be_valid
    end

    # it "n'est pas valide sans price" do
    #   product = Product.new(valid_attributes.except(:prices_attributes))
    #   expect(product).not_to be_valid
    # end
  end

  describe "création" do
    it "crée un nouveau produit avec un prix associé" do
      expect {
        product = Product.create!(valid_attributes)
        expect(product.prices.first.amount).to eq(19.99)
      }.to change(Product, :count).by(1)
      .and change(Price, :count).by(1)
    end
  end

  describe "modification" do
    let!(:product) { Product.create!(valid_attributes) }

    it "met à jour le produit et son prix" do
      expect {
        product.update!(
          name: "Nouveau nom", 
          prices_attributes: { "0" => { id: product.prices.first.id, amount: 29.99 } }
        )
      }.to change { product.reload.name }.to("Nouveau nom")
      .and change { product.reload.prices.first.amount.to_f }.to(29.99)
    end
  end

  describe "suppression" do
    let!(:product) { Product.create!(valid_attributes) }

    it "supprime un produit existant et son prix associé" do
      expect {
        product.destroy
      }.to change(Product, :count).by(-1)
      .and change(Price, :count).by(-1)
    end
  end
end
