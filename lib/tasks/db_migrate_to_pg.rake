namespace :db do
  desc 'Migrate data from SQLite to PostgreSQL'
  task :migrate_to_pg => :environment do
    require 'sequel'
    
    # Connexion aux bases de données
    source_db = Sequel.connect('sqlite://db/development.sqlite3')
    target_db = Sequel.connect('postgres://simple_crm:your_password@localhost/development')
    
    # Liste des tables à migrer (exclure schema_migrations et ar_internal_metadata)
    tables = source_db.tables.reject { |t| [:schema_migrations, :ar_internal_metadata].include?(t) }

    puts "Starting migration from SQLite to PostgreSQL..."
    
    # 1. Charger le schéma dans PostgreSQL
    puts "Loading schema into PostgreSQL..."

    # Sauvegarde de database.yml
    FileUtils.cp('config/database.yml', 'config/database.yml.backup')
    
    # Modification temporaire pour créer le schéma dans PostgreSQL
    db_config = YAML.load_file('config/database.yml', aliases: true)

    db_config['development'] = db_config['development'].merge({
      'adapter' => 'postgresql',
      'encoding' => 'unicode',
      'host' => 'localhost',
      'username' => 'simple_crm',
      'password' => 'your_password',
      'database' => 'development'
    })
    
    File.open('config/database.yml', 'w') do |f|
      f.write(db_config.to_yaml)
    end
    
    # Avant le chargement du schéma et des données on descative les contraintes de clés etrangères
    ActiveRecord::Base.connection.execute("SET session_replication_role = 'replica';")

    # Chargement du schéma
    Rake::Task['db:schema:load'].invoke
    
    # Restauration de database.yml
    FileUtils.cp('config/database.yml.backup', 'config/database.yml')
    
    # 2. Migration des données table par table
    tables.each do |table|
      puts "Migrating table: #{table}"
      records = source_db[table].all
      
      # Désactiver les triggers pour éviter problèmes avec séquences PG
      target_db.run("ALTER TABLE #{table} DISABLE TRIGGER ALL") rescue nil
      
      # Insérer les données
      records.each do |record|
        begin
          target_db[table].insert(record)
        rescue => e
          puts "Error inserting record in #{table}: #{e.message}"
          puts "Record: #{record.inspect}"
        end
      end
      
      # Réactiver les triggers
      target_db.run("ALTER TABLE #{table} ENABLE TRIGGER ALL") rescue nil
      
      # Mise à jour des séquences pour les clés primaires auto-incrémentées
      begin
        target_db.run("SELECT setval('#{table}_id_seq', (SELECT MAX(id) FROM #{table}))")
      rescue => e
        puts "Warning: Could not update sequence for #{table}: #{e.message}"
      end
      
      puts "Migrated #{records.count} records from table #{table}"
    end
    #on remet la contrainte de clé etrangère
    ActiveRecord::Base.connection.execute("SET session_replication_role = 'origin';")
    
    puts "Migration completed!"
  end
end
