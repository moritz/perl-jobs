navigator.id.watch({
    loggedInUser: App.Config.email,
    onlogin: function(assertion) {
        if (App.Config.email)
            return;
        $.ajax({
            type: 'POST',
            url: '/login',
            data: {assertion: assertion},
            success: function(res, status, xhr) { alert('You are now logged in!'); window.location.reload(); },
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
            success: function(res, status, xhr) { alert('logged out'); },
            error: function(xhr, status, err) { alert("Logout failure: " + err); }
        });
    }
  });



$(document).ready(function() {
    // persona log-in
    $('#app-login').click(function() {
        alert('login');
        navigator.id.request();
    })
    $('#app-logout').click(function() {
        navigator.id.logout();
    });

});
