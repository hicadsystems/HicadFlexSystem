function xprsspayment(el) {
    ShowLoading();
    var model = $("#frmCreatePayment").serializeObject();
    var url = applicationBaseUrl + '/XpressPay/InitializePayment';
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
////}
//function xprsspayment(el) {
//    ShowLoading();
//    var url = $(el).attr('data-url');
//    var model = $("#frmCreatePayment").serializeObject();
//        $.ajax({
//            url: url,
//            type: "POST",
//            data: { model: model },
//            success: function (data) {
//                console.log(data);
//                //window.location.href = applicationBaseUrl + '/DashBoard';
//                //toastr.success(data, "Approval")
//                HideLoading();
//            },
//            error: function (resp) {
//                if (resp.status === 401) {
//                    window.location.href = loginurl;
//                }
//                toastr.error(resp.statusText, "Error");
//                HideLoading();
//            }
//        });
   
}