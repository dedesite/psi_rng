# Ramaze Psi Rng website

It's time to create a real website for this project. I choose to use the Ruby's Ramaze framework which is certainly not the most known Ruby's framework but I found it quite simple to understand and I already used it for previous project.

# Set up

	bundle update
	bower update
	#Assuming user/pass is root
	mysql --user=root --password=root
	create database psi_rng;
	exit;
	sequel -m db/migrations mysql2://root:root@localhost/psi_rng
	rake ramaze:start