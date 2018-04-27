
var ajaxRequest;

$('form').on('submit', function(form) {
    form.preventDefault();

    var login = $('#inputLogin').val();
    var password = $('#inputPassword').val();
    var errorMessage = document.getElementById("errorMessage");

    if (login != "" && password != "") {

        var uri = "/login";
        var json = {"login": login, "password": password};

        ajaxRequest = $.ajax({
            url: uri,
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(json)
        });

        /* Alert the user when finished without error */
        ajaxRequest.done(function (response, textStatus, jqXHR){
            //alert(JSON.stringify(response));
            console.error(response)
            if (response["success"] != true) {
                
                errorMessage.innerHTML = "<font color=\"RED\">Credentials error</font>"
                errorMessage.hidden = false
            } else {
                window.location.href = "/"
                errorMessage.hidden = true
            }
        });

        /* If the call fails  */
        ajaxRequest.fail(function (jqXHR, textStatus, errorThrown){
            // Log the error
            console.error(
                "The following error occurred: " + textStatus, errorThrown
            );
        });

        $('#inputLogin').val('');
        $('#inputPassword').val('');
    }
});
