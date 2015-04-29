

// Get the full group hierarchy for a given user
// @param: 'userId'

// 		{"userId":"kRaibtYs3r"}

Parse.Cloud.define("getGroupsForUser", function(request, response) {
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
			queryConvo.include('incode');
			queryConvo.find({
				success: function(convos) {
					var groups = {};
					groups.push("hola");

					// for (var i = 0; i < convos.length; i++) {
					// 	var convo = convos[i];
					// 	// var group = convo['groupId'].fetch();
					// 	groups.push("hello");
					// 	// Get the parent group of each Convo
						
					// }

					response.success(groups);
				},
				error: function(convos, error) {
					response.error("Failed to retrieve user's groups: " + error);
				}
			})
		},
		error: function(user, error) {
			response.error("Failed to retrieve user: " + error);
		}
	});
});


//adding a convo to a group
// Parse.Cloud.define("addConvotoGroup", function(request,response){
// 	var queryConvo
// });
