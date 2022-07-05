$('#btnlogin').click(function () {
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
            //if (data.Status == 7) {
            //    toastr.error("Invalid User Name/ Password", "Login Error");
            //}
            //else {
            //    authObj = data;
            //    window.location.href = '/DashBoard';
            //}
            authObj = data;
            Cookies.set("auth", JSON.stringify(authObj));
            if (data.Status == 1) {
                //window.location.href = '/DashBoard';
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
            toastr.error("Invalid User Name/ Password", "Login Error");
            HideLoading();
        }
    });
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
        var url = changePasswordUrl;
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            hideModal();
            if (resp.Description == 'Password Changed Successfully') {
                toastr.success(resp.Description, "Password Change");
                if (action == 'login') {
                    //window.location.href = '/DashBoard';
                    window.location.href = dashboardurl;
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

function showChangePassword() {
    showModalfromfile('appFiles/changePassword.html', 'Change Password', 'xPass()')
}
function showChangePayment() {

    showModalfromfile('appFiles/ussd.html', 'Change Password', 'xPass()')
}

$('#btnlogOut').click(function () {
    ShowLoading();
    window.location.href = loginurl;
    HideLoading();
});

function ShowLoading() {
    $('#ajax').modal({ backdrop: 'static', keyboard: false });
}

function HideLoading() {
    $('#ajax').modal('hide');
}