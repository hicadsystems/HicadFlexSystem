function searchAgent(el, page) {
    ShowLoading();
    var searchModel = searchModel || {};


    var name = document.getElementById('agName').value;
    var type = document.getElementById('agType').value;
    var location = document.getElementById('agLocation').value;

    searchModel.Name = name;
    searchModel.Type = type;
    searchModel.Location = location;

    pageModel.Page = page;
    searchModel.Page = pageModel;

    var data = { searchmodel: searchModel };
    var url = $(el).attr('data-url');

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbagents');
        pagediv.innerHTML = resp;
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
}
