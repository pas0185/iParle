Parse.Cloud.define("getBlurb", function(request, response){
	var query = new Parse.Query("Blurb")
	var user = request.user
	query.equalTo("userId", user);
	query.equalTo("convoId", request.params.convoId)
	query.find({
		success: function(results){	
		var sum = 0;
			for (var i = 0; i < results.length; ++i) {
        	sum += results[i].get("text");
			}
		response.success(sum / results.length);
	},
	error: function()
	{
		response.error("Cannot load blurbs")
	}
	});
});