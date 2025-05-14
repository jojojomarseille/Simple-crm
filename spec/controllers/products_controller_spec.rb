# spec/controllers/products_controller_spec.rb
require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  # Créer une organisation à utiliser dans tous les tests
  let(:organisation) { Organisation.create!(business_name: "Organisation Test") }
   # Créer un utilisateur et le connecter
  let(:user) { User.create!(email: "test@example.com", password: "password123", organisation: organisation) }
  
  before do
    sign_in user
  end

  let(:valid_attributes) do
    {
      name: "Produit test",
      description: "Description du produit test",
      organisation_id: organisation.id,
      prices_attributes: { "0" => { amount: 19.99 } }
    }
  end

  let(:invalid_attributes) do
    {
      name: "",
      description: nil,
      organisation_id: organisation.id,
      prices_attributes: { "0" => { amount: nil } }
    }
  end

  describe "GET #index" do
    it "affiche une liste de produits" do
      product = Product.create!(valid_attributes)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "affiche le produit demandé" do
      product = Product.create!(valid_attributes)
      get :show, params: { id: product.id }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "affiche le formulaire pour un nouveau produit" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "affiche le formulaire d'édition d'un produit" do
      product = Product.create!(valid_attributes)
      get :edit, params: { id: product.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "avec des attributs valides" do
      it "crée un nouveau produit" do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it "crée un nouveau prix pour le produit" do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Price, :count).by(1)
      end

      it "redirige vers le produit créé" do
        post :create, params: { product: valid_attributes }
        expect(response).to redirect_to(Product.last)
      end
    end

    context "avec des attributs invalides" do
      it "ne crée pas de nouveau produit" do
        expect {
          post :create, params: { product: invalid_attributes }
        }.to change(Product, :count).by(0)
      end

      # it "renvoie un statut unprocessable_entity" do
      #   post :create, params: { product: invalid_attributes }
      #   expect(response).to have_http_status(:unprocessable_entity)
      # end
    end
  end

  describe "PUT #update" do
    let!(:product) { Product.create!(valid_attributes) }

    context "avec des attributs valides" do
      let(:new_attributes) { 
        { 
          name: "Nom mis à jour", 
          prices_attributes: { "0" => { id: product.prices.first.id, amount: 49.99 } }
        } 
      }

      it "met à jour le produit et son prix" do
        put :update, params: { id: product.id, product: new_attributes }
        product.reload
        expect(product.name).to eq("Nom mis à jour")
        expect(product.prices.first.amount).to eq(49.99)
      end

      it "redirige vers le produit" do
        put :update, params: { id: product.id, product: new_attributes }
        expect(response).to redirect_to(product)
      end
    end

    context "avec des attributs invalides" do
      it "ne met pas à jour le produit" do
        original_name = product.name
        put :update, params: { id: product.id, product: invalid_attributes }
        expect(product.reload.name).to eq(original_name)
      end

      # it "renvoie un statut unprocessable_entity" do
      #   put :update, params: { id: product.id, product: invalid_attributes }
      #   expect(response).to have_http_status(:unprocessable_entity)
      # end
    end
  end

  describe "DELETE #destroy" do
    let!(:product) { Product.create!(valid_attributes) }

    it "détruit le produit et son prix" do
      expect {
        delete :destroy, params: { id: product.id }
      }.to change(Product, :count).by(-1)
      .and change(Price, :count).by(-1)
    end

    it "redirige vers la liste des produits" do
      delete :destroy, params: { id: product.id }
      expect(response).to redirect_to(products_url)
    end
  end
end
