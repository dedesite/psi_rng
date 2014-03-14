# Api documentation

## Error code

L'usage de 401 et 403 est inspiré de l'API google drive 

1. 400 => La syntaxe de la requète est mauvaise. Soit il manque des paramètres, soit le format des paramètres n'est pas valide (String à la place d'Integer ou Sql Validation failed) 

2. 401 => Ce service requiert une authentification et l'utilisateur n'est pas authentifié

3. 403 => L'utilisateur est authentifié mais n'est pas authorizé 

4. 404 => La ressource n'est pas trouvée. La syntaxe de la requète est bonne mais les paramètres ne correspondent pas à une ressource existante (ex : user non existant) ou ne sont pas logique par rapport au path. Ex : l'email n'appartient pas à l'utilisateur dans /user/:user_id/email/:email_id

5. 405 => Si le verbe HTTP utilisé pour un path n'existe pas (exemple appel de DELETE pour un url disponible uniquement en GET) et quand l'url n'existe pas.

6. 200 => success pour les requete (GET, DELETE, PUT)

7. 201 => success pour la requête (POST)

## Api user

### GET /api/user

No parameters
Return current user informations

### POST /api/user/login

- email : email of the user
- password : password of the user

Login a user, return the current user if successful
return user token that is stored in DB and used by the user for every requests

### GET /api/user/:id

Return a specific user info

### POST/PUT /api/user

- email (only for post)
- password
- age
- laterality
- believer
- sex

Create/modify a user
Note : for the moment, the service is in private beta stage so we'll have a white list of emails that can register.

## Api Queue

### GET /api/queue/state

return {estimated_time: 500, queue_length: 3}

### GET /api/queue/:id

return {id: 3, estimated_time: 500, ready: false}

Note : used to tell the server we are still waiting. If not called every 30s the queue item is automatically remove.

### POST /api/queue

{xp_id: 123}

return GET /api/queue/:id

### DELETE /api/queue/:id

remove a user from the queue

### POST /api/queue/:id/start

Tell the server that we start the experiment.

return an RNG object like {id: 1, url: "81.81.18.12"}

Note : If we don't start the experiment within 30s, the queue item is automatically removed from queue.

## Api results

POST /api/results

{xp_id: 123, music: "mozart", drug: ["coffee", "tabac"], raw_numbers: [255, 128, 65, 37...], alone: true, rng_id: 1, results : {one_zero_diff: [2, 45, -12, ..., 98]}}

