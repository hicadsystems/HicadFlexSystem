function memberList() {
    ShowLoading();

    var isvallid = ValidateInput('#memList');
    if (isvallid) {
        var form = $("#memList");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + "/Report/MemberResgister";
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar");
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}


function toggleType(el) {
    if ($(el).val() == 'Agent') {
        $('#divAgent').show();
        $('#divLocation').hide();
    }
    if ($(el).val() == 'Branch') {
        $('#divAgent').hide();
        $('#divLocation').show();
    }
}

function toggleSortOrder(el) {
    if ($(el).val() == 'policy') {
        $('#divAgent').hide();
        $('#divLocation').hide();
        $('#divPolicy').show();
        $('#divCustomerLocation').hide();
    }
    else if ($(el).val() == 'agent') {
        $('#divAgent').show();
        $('#divLocation').hide();
        $('#divPolicy').hide();
        $('#divCustomerLocation').hide();
    }
    else if ($(el).val() == 'location') {
        $('#divAgent').hide();
        $('#divLocation').show();
        $('#divPolicy').hide();
        $('#divCustomerLocation').hide();
    }
    else if ($(el).val() == 'custlocation') {
        $('#divAgent').hide();
        $('#divLocation').hide();
        $('#divPolicy').hide();
        $('#divCustomerLocation').show();
    }
}

function statement() {
    ShowLoading();
    var isvallid = ValidateInput('#statement');
    if (isvallid) {
        var form = $("#statement");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url =applicationBaseUrl +  "/Report/PrintStatment"
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar")
            //var blob = new Blob([resp], { type: "application/pdf" });
            //var link = document.createElement('a');
            //link.href = window.URL.createObjectURL(blob);
            //link.download = "memberList.pdf";
            //link.click();
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}

function invHistory() {
    ShowLoading();
    var isvallid = ValidateInput('#investment')
    if (isvallid) {
        var form = $("#investment");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + "/Report/Investment"
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar")
            //var blob = new Blob([resp], { type: "application/pdf" });
            //var link = document.createElement('a');
            //link.href = window.URL.createObjectURL(blob);
            //link.download = "memberList.pdf";
            //link.click();
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}

function production() {
    ShowLoading();
    var isvallid = ValidateInput('#production');
    if (isvallid) {
        var form = $("#production");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + "/Report/Production";
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar");
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}

function recieptListing() {
    ShowLoading();
    var isvallid = ValidateInput('#recieptList');
    if (isvallid) {
        var form = $("#recieptList");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + "/Report/Reciept";
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar");
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}

function fundGroup() {
    ShowLoading();
    var isvallid = ValidateInput('#fundgroup');
    if (isvallid) {
        
        var lamt = document.getElementById('lower').value;
        var uamt = document.getElementById('upper').value;
        var url = applicationBaseUrl + "/Report/FundGroup";
        var data = { lamt: lamt, uamt: uamt };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar");
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}

function commission() {
    ShowLoading();
    var isvallid = ValidateInput('#commision');
    if (isvallid) {
        var form = $("#commision");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + "/Report/Commission";
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar");
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}

function maturityList() {
    ShowLoading();

    var url = applicationBaseUrl + "/Report/Maturity";
    var Promise = Post(url, null, 'Post');

    Promise.done(function (resp) {
        HideLoading();
        window.open(resp, "resizeable,scrollbar");
    });

    Promise.fail(function (resp) {
        if (resp.status === 401) {
            //window.location.href = '/Login';
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}
function togglegreport(el) {
    var rptType = el.value;
    var divSingle = document.getElementById('divSingle')
    var divAll = document.getElementById('divAll')
    if (rptType == 'Single') {
        divSingle.style.display = 'block';
        divAll.style.display = 'none';
    }
    else {
        divSingle.style.display = 'none';
        divAll.style.display = 'block';
    }
}
function gratuityReport() {
    ShowLoading();
    var isvallid = ValidateInput('#greport')
    if (isvallid) {
        var form = $("#greport");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + "/Report/Gratuity"
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            window.open(resp, "resizeable,scrollbar")
            //HideLoading();
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}
//function statement() {
//    ShowLoading();
//    var isvallid = ValidateInput('#statement')
//    if (isvallid) {
//        var form = $("#statement");
//        var query = form.serializeObject();
//        var queryj = JSON.stringify(query);
//        var url = "/Report/PrintStatment"
//        var data = { queryj: queryj };

//        var http = new XMLHttpRequest();
//        var params = data;
//        http.open("POST", url, true);
//        http.responseType = 'blob';
//        http.setRequestHeader("Content-type", "application/formdata; charset=utf-8");
//        //http.setRequestHeader("Content-length", params.length);
//        //http.setRequestHeader("Connection", "close");

//        http.onload = function (e) {
//            if (this.status == 200) {
//                // Note: .response instead of .responseText
//                var blob = new Blob([this.response], { type: 'application/pdf' }),
//                    url = URL.createObjectURL(blob),
//                    _iFrame = document.createElement('iframe');

//                _iFrame.setAttribute('src', url);
//                _iFrame.setAttribute('style', 'visibility:hidden;');
//                $('#custpolContent').append(_iFrame)
//                HideLoading();
//            }
//        };
//        http.send(params);
//    }
//}