function createPolicy(el) {
    ShowLoading();
    var model = $("#frmCreatePolicy").serializeObject();
    alert("i am here")
    var url = applicationBaseUrl + '/CustPolicy/CreateAddPolicy';
    var data = { model: model };
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        toastr.success(data, "Policy Creation")
        window.location.href = applicationBaseUrl + '/Customers';
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