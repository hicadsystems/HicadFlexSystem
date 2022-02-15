$('#mnubtnHome').click(function () {
    ShowLoading();
    //window.location.href = '/DashBoard';
    window.location.href = $(this).attr('data-url');
    HideLoading();
});

function LoadPage(btn){
    console.log(btn);
    ShowLoading();
    var url = $(btn).attr('data-url');
    var pagePromise = Post(url, '', 'get');

    pagePromise.done(function (resp) {
        var pagediv=document.getElementById('custpolContent');
        pagediv.innerHTML = resp;
        jQuery(document).trigger("date_picker");
        jQuery(document).trigger("select2");
        HideLoading();
    });

    pagePromise.fail(function (resp) {
        if (resp.status === 401) {
            //window.location.href = '/Login';
            window.location.href = loginurl;
        }
        toastr.error("Page Load Error", "Error");
        HideLoading();

    });
    //HideLoading();
};
