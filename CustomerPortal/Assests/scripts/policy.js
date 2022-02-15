function createPolicy(el) {
    ShowLoading();
    var model = $("#frmCreatePolicy").serializeObject();
    var url =applicationBaseUrl + '/Policy/Create';
    var data = { model: model };
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        toastr.success(data, "Policy Creation")
        window.location.href = applicationBaseUrl + '/DashBoard';
        HideLoading();
    });

    Promise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}