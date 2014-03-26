Sequel.migration do
  up do
    create_table(:user) do
      primary_key :id
      String :email, :null=>false
      String :password
      String :token
      Integer :age
      String :laterality
      String :believer
      String :sex
    end

    create_table(:xp) do
    	primary_key :id
    	String :name
    end

    create_table(:rng) do
    	primary_key :id
    	String :url
    	TrueClass :status
    end

    create_join_table(:user_id=>:user, :xp_id=>:xp) do
    	Time :xp_time
    	String :music
    	String :drug
    	String :raw_numbers
    	String :results
    	TrueClass :alone
    	Integer :rng_id
    	foreign_key [rng_id], :rng
    end
  end

  down do
    drop_table(:user)
    drop_table(:xp)
    drop_table(:rng)
    drop_table(:user_xp)
  end
end