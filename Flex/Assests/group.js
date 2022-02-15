function searchGroup(term, page, size) {
    var spinner = document.getElementById('searching');
    spinner.style.display = 'block';
    var data = { searchterm: term, page: page, pagesize: size };
    var url =applicationBaseUrl + '/SetUp/SearchGroup';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbgroup');
        pagediv.innerHTML = resp;
        spinner.style.display = 'none';
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); spinner.style.display = 'none';
    });
}
