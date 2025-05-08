class BaseCompany < ApplicationRecord
    # include Elasticsearch::Model
    # include Elasticsearch::Model::Callbacks
  
    # settings index: { number_of_shards: 1 } do
    #   mappings dynamic: false do
    #     indexes :siret, type: 'keyword'
    #     indexes :siren, type: 'keyword'
    #     indexes :denomination_sociale, type: 'text'
    #     indexes :marque, type: 'text'
    #     indexes :adresse, type: 'text'
    #     indexes :code_postal, type: 'keyword'
    #     indexes :statut, type: 'keyword'
    #     indexes :pays, type: 'keyword'
    #     indexes :date_derniere_modification, type: 'date'
    #     indexes :date_creation, type: 'date'
    #   end
    # end
  
    # def self.search(query)
    #   __elasticsearch__.search(
    #     {
    #       query: {
    #         multi_match: {
    #           query: query,
    #           fields: ['denomination_sociale^3', 'siret', 'marque']
    #         }
    #       },
    #       size: 10
    #     }
    #   )
    # end
  
end
