
var Convo = Parse.Object.extend("Convo");
var User = Parse.Object.extend("User");

// Add an existing user to an existing conversation
// @params: 'username' and 'convoId' 
Parse.Cloud.define("addUserToConvoByUsername", function(request, response) {

	var queryUser = new Parse.Query("User");
	var queryConvo = new Parse.Query("Convo");

	queryUser.equalTo("username", request.params.username)
	
	queryUser.find({
		success: function(user) {
			// Successfully found the user
			queryConvo.get(request.params.convoId, {
				success: function(convo) {
					// Successfully found the convo
					var relation = convo.relation("users");
					relation.add(user);
					convo.save(null, {
						success: function() {
							response.success("Successfully added user to convo");
						},
						error: function(error) {
							response.error("Failed to add user (" + user + ") to convo: " + error);
						}
					});
				},
				error: function(convo, error) {
					response.error("Failed to retrieve convo: " + error);
				}
			});
		},
		error: function(user, error) {
			response.error("Failed to retrieve user: " + error);
		}
	});
});


// Add an existing user to an existing conversation
// @params: 'userId' and 'convoId' 
Parse.Cloud.define("addUserToConvoById", function(request, response) {

	var queryUser = new Parse.Query("User");
	var queryConvo = new Parse.Query("Convo");

	queryUser.get(request.params.userId, {
		success: function(user) {
			// Successfully found the user
			queryConvo.get(request.params.convoId, {
				success: function(convo) {
					// Successfully found the convo
					var relation = convo.relation("users");
					relation.add(user);
					convo.save(null, {
						success: function() {
							response.success("Successfully added user to convo");
						},
						error: function(error) {
							response.error("Failed to add user to convo: " + error);
						}
					});
				},
				error: function(convo, error) {
					response.error("Failed to retrieve convo: " + error);
				}
			});
		},
		error: function(user, error) {
			response.error("Failed to retrieve user: " + error);
		}
	});
});


// Get Convos for a given user
// @param: 'userId'

// 		{"userId":"kRaibtYs3r"}
Parse.Cloud.define("getConvosForUser", function(request, response) {
	// Group.js
	var User = Parse.Object.extend("User");
	var Group = Parse.Object.extend("Group");
	var Convo = Parse.Object.extend("Convo");

	var queryUser = new Parse.Query("User");
	var queryConvo = new Parse.Query("Convo");
	var queryGroup = new Parse.Query("Group");

	queryUser.get(request.params.userId, {
		success: function(user) {
			// Successfully found user, get all conversations subscribed to
			queryConvo.equalTo("users", user);
			queryConvo.include('groupId');
			queryConvo.find({
				success: function(convos) {
					response.success(convos);
				},
				error: function(convos, error) {
					response.error("Failed to retrieve user's convos: " + error);
				}
			})
		},
		error: function(user, error) {
			response.error("Failed to retrieve user: " + error);
		}
	});
});