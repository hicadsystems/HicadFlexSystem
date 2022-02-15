$(function () {

    $('#btnlogin').click(function () {

        login();
    });

    $('#btnlogOut').click(function () {
        ShowLoading();
        //window.location.href = '/Login'
        window.location.href = loginurl;

        HideLoading();
    });

    function ShowLoading() {
        $('#ajax').modal({ backdrop: 'static', keyboard: false });
    }

    function HideLoading() {
        $('#ajax').modal('hide');
    }

    function login() {
        ShowLoading();
        console.log('About to login');
        var form = $("#loginForm");
        var url = form.attr("action");
        var username = $("#username").val();
        var password = $("#password").val();
        $.ajax({
            url: url,
            type: "POST",
            data: { username: username, password: password },
            success: function (data) {
                authObj = data;
                Cookies.set("auth", JSON.stringify(authObj));
                Cookies.set("Module", document.getElementById('Module').value);
                console.log(Cookies.get('Module'));
                var authObj = Cookies.getJSON("auth");
                console.log(authObj);
                if (data.Status == 1) {
                    //window.location.href = '~/DashBoard';

                    window.location.href = dashboardurl;
                }
                else if (data.Status == 0 || data.Status == 4) {
                    showModalfromfile('appFiles/changePassword.html', 'Change Password', "xPass('login')")
                }
                else {
                    toastr.error(data.Description, "Login Error");
                }
                HideLoading();

            },
            error: function (resp) {
                toastr.error(resp.statusText, "Login Error");
                HideLoading();
            }

        });

        return false;
    }


    $('form[data-ajax="true"]').submit(login)
});

function xPass(action) {
    var isValid = ValidateInput("xpass");
    if (isValid) {
        var xpwd = $("#xpass").serializeObject();
        if (xpwd.NewPassword != xpwd.ReNewPassword) {
            toastr.error("Please confirm your password", "Change Password");
            return;
        }
        ShowLoading();
        var data = { xpass: xpwd };
        var url = applicationBaseUrl + '/Login/ChangePassword';
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            hideModal();
            if (resp.Description == 'Password Changed Successfully') {
                toastr.success(resp.Description, "Password Change");
                if (action == 'login') {
                    window.location.href = dashboardurl;//'/DashBoard';
                }
            } else {
                toastr.error(resp.Description, "Error");
            }

            HideLoading();
        });

        Promise.fail(function (resp) {
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }


}

