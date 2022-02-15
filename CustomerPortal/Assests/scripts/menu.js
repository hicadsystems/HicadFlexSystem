
function LoadPage(btn){
    console.log(btn);
    ShowLoading();
    var url = $(btn).attr('data-url');
    var pagePromise = Post(url, '', 'get');

    pagePromise.done(function (resp) {
        if (resp === "") {
            window.location.href = loginurl;;
        }
        var pagediv = document.getElementById('divcontent');
        pagediv.innerHTML = resp;
        jQuery(document).trigger("date_picker");
        HideLoading();
    });

    pagePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error("Page Load Error", "Error");
        HideLoading();

    });
    //HideLoading();
};
