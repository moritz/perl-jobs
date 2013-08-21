


$(document).ready(function() {
    // persona log-in
    $('#app-login').click(function() {
        navigator.id.request();
    })
    $('#app-logout').click(function() {
        navigator.id.logout();
    });
    navigator.id.watch({
        loggedInUser: App.Config.email,
        onlogin: function(assertion) {
            if (App.Config.email)
                return;
            $.ajax({
                type: 'POST',
                url: '/login',
                dataType: 'json',
                data: {assertion: assertion},
                success: function(res, status, xhr) {
                    console.log(res);
//                    alert('You are now logged in as' + res[email]);
//                    App.Config.email = res[email];
                    window.location.reload();
                },
                error: function(xhr, status, err) {
                    navigator.id.logout();
                    alert("Login failure: " + err);
                }
            });
        },
        onlogout: function() {
            if (App.Config.email === null)
                return;
            $.ajax({
            type: 'POST',
            url: '/logout',
                success: function(res, status, xhr) { window.location.reload(); },
                error: function(xhr, status, err) { alert("Logout failure: " + err); }
            });
        }
    });

});
