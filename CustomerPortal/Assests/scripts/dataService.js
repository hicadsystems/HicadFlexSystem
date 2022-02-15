function Post(url, data, type) {
    //ShowLoading();

    var promise=
    $.ajax({
        beforeSend: function (xhr) {
            xhr.setRequestHeader('authToken', getAuthToken());
        },
        type: type,
        url: url,
        data:data
    });
    //HideLoading();
    return promise;
}