function readURL(input) {

    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {
            $('#img_signup_settings').attr('src', e.target.result);
        }

        reader.readAsDataURL(input.files[0]);
    }
}

$(document).ready(function(){
	var txtlinks = $("#beautiful-link").text();
    var linksarr = txtlinks.split(" ");
    var finlinks = "";
    linksarr.forEach(function(item, i, linksarr)
    {
        finlinks += "<a href=\"#\" style=\"font-size: " + (Math.random()*(32 - 16) + 16) + "px; color: #" + Math.floor(Math.random() * 16777215).toString(16) + ";\">" + item + " </a>";
    });
    $("#beautiful-link").html(finlinks);
});

$(document).ready(function() {
	$( "input[type='file']" ).change(function() {
		readURL(this);
	});
});
