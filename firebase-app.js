var FirebaseServer = require('firebase-server');
FirebaseServer.enableLogging(true);

new FirebaseServer(5111, 'local.firebaseio.com',
{
  "clans" : {
    "simplelogin:1" : {
      "clan_size" : "village",
      "morale" : 70,
      "name" : "Karolann",
      "population" : 3,
      "timestamp" : 93922,
      "village_id" : 1
    }
  },
  "users" : {
    "simplelogin:1" : {
      "name" : "Tyler James"
    }
  }
});
