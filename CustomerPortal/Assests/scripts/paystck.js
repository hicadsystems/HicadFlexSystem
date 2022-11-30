function payWithPaystack(el) {
    ShowLoading();
    var model = $("#paymentForm").serializeObject();
    var url = applicationBaseUrl + '/XpressPay/initiatepaystack';
    var data = { model: model };
    var Promise = Post(url, data, 'Post');

    //console.log(Promise);
    Promise.done(function (resp) {
        toastr.success(data, "Procceed to payment")
        //console.log(resp);
        window.open(resp);
        HideLoading();
    }).then(res => {
        //console.log(res);
        window.open(resp);
    });

    Promise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });

}