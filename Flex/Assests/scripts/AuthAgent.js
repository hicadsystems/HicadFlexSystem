$(function () {

    $('#btnlogin').click(function () {

        agentlogin();
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

    function agentlogin() {
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
               /* alert("i am here 3")*/
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
                    alert("i am here 1")
                    showModalfromfile('appFiles/changePassword.html', 'Change Password', "xPass('agentlogin')")
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


    $('form[data-ajax="true"]').submit(agentlogin)
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
        var url = applicationBaseUrl + '/AgentLogin/ChangePassword';
        var Promise = Post(url, data, 'Post');
        alert("i am here 2")
        Promise.done(function (resp) {
            hideModal();
            if (resp.Description == 'Password Changed Successfully') {
                toastr.success(resp.Description, "Password Change");
                if (action == 'agentlogin') {
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

