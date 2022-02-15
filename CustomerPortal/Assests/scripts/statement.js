function toggleSearchoption() {
    var opt = document.getElementById('searchoption').value;
    var divmth = document.getElementById('divmth');
    var divyr = document.getElementById('divyr');
    var divdtfrm = document.getElementById('divdatefrom');
    var divdtto = document.getElementById('divdateto');

    if (opt==0) {
        divmth.style.display = "block";
        divyr.style.display = "block";
        divdtfrm.style.display = "none";
        divdtto.style.display = "none";

    } else {
        divdtfrm.style.display = "block";
        divdtto.style.display = "block";
        divmth.style.display = "none";
        divyr.style.display = "none";

    }
}

function searchStatement(el) {
    ShowLoading();
    var stmtQuery = $("#stmtSearch").serializeObject();
    var url = $(el).attr('data-url');
    var data = { stmtquery: stmtQuery };
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        ShowLoading();
        var tbDiv = document.getElementById('tbstmt');
        tbDiv.innerHTML = resp;
        tbDiv.style.display = "block";
        HideLoading();
    });

    Promise.fail(function (resp) {
        ShowLoading();
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}
