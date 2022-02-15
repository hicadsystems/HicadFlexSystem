function claimProcess(Id, type) {
    ShowLoading();
    if (type == 'disapprove') {
        var dis = getConfirmation();
        if (!dis) {
            HideLoading();
            return;
        }
    }
    var url = applicationBaseUrl + '/Claim/ClaimProcess';
    var data = { id: Id, processingType : type};
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        if (type =='disapprove') {
            var pageview = document.getElementById('custpolContent');
            pageview.innerHTML = resp;
        }
        else if (type == 'process') {
            showModal(resp, 'Process Claim', 'processClaim()');
        }
        else if(type=='approve') {
            showModal(resp, 'Approve Claim', 'approveClaim()');
        }
        else if (type == 'pay') {
            showModal(resp, 'Claim Payment', 'payClaim()');
        }
        HideLoading();
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

function processClaim() {
    ShowLoading();
    hideModal();
    var isvalid = ValidateInput('#pclaim')
    if (isvalid) {
        var model = $("#pclaim").serializeObject();
        var queryj = JSON.stringify(model);
        var url = applicationBaseUrl + '/Claim/ProcessClaim';
        var data = { query: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar")
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    } else {
        HideLoading();
    }

}

function approveClaim() {
    ShowLoading();
    hideModal();
    var isvalid = ValidateInput('#apclaim')
    if (isvalid) {
        var model = $("#apclaim").serializeObject();
        var queryj = JSON.stringify(model);
        var url = applicationBaseUrl + '/Claim/ApproveClaim';
        var data = { query: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar")
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    } else {
        HideLoading();
    }

}

function getConfirmation() {
    var retVal = confirm("Do you want to Disapprove Claim?");
    if (retVal == true) {
        return true;
    }
    else {
        return false;
    }
}

function searchClaim() {
    ShowLoading();
    var sDate = document.getElementById('txtdatefrom').value;
    var eDate = document.getElementById('txtdateto').value;

    var url =applicationBaseUrl + '/Claim/SearchClaim';
    var data = { sdate: sDate, edate: eDate };
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        var divcontent = document.getElementById('tbclmReq');
        divcontent.innerHTML = resp;
        //toastr.success(resp, "Claim Request");
        HideLoading();
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

function showAmount(el) {
    console.log(el);
    var amtdiv = document.getElementById('divamt');
    if (el.value == 0) {
        amtdiv.style.display = 'block';
    }
    else {
        amtdiv.style.display = 'none';
    }
}

function searchClaimpayment() {
    ShowLoading();
    var sDate = document.getElementById('txtdatefrom').value;
    var eDate = document.getElementById('txtdateto').value;
    var policyno = document.getElementById('policyno').value;
    var claimno = document.getElementById('claimno').value;


    var url = applicationBaseUrl + '/Claim/SearchClaimPay';
    var data = { sdate: sDate, edate: eDate, policyno: policyno,claimno:claimno };
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        var divcontent = document.getElementById('tbclmReq');
        divcontent.innerHTML = resp;
        //toastr.success(resp, "Claim Request");
        HideLoading();
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

function payClaim() {
    ShowLoading();
    hideModal();
    var isvalid = ValidateInput('#claimpay')
    if (isvalid) {
        var model = $("#claimpay").serializeObject();
        var queryj = JSON.stringify(model);
        var url = applicationBaseUrl + '/Claim/PayClaim';
        var data = { query: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            toastr.success(resp, "Claim Payment");
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    } else {
        HideLoading();
    }

}

function toggleclaimreport(el) {
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

function claimReport() {
    ShowLoading();
    var isvalid = ValidateInput('#claimrpt')
    if (isvalid) {
        var model = $("#claimrpt").serializeObject();
        var queryj = JSON.stringify(model);
        var url =applicationBaseUrl + '/Claim/ClaimReport';
        var data = { query: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar")
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    } else {
        HideLoading();
    }

}

function claimDateRange() {
    ShowLoading();
    var isvalid = ValidateInput('#claimrpt')
    if (isvalid) {
        var model = $("#claimrpt").serializeObject();
        var queryj = JSON.stringify(model);
        var url = applicationBaseUrl + '/Claim/ClaimDate';
        var data = { query: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            window.open(resp, "resizeable,scrollbar")
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    } else {
        HideLoading();
    }

}

function policyReactivation() {
    ShowLoading();
    var isvalid = ValidateInput('#policyRe')
    if (isvalid) {
        var model = $("#policyRe").serializeObject();
        //var queryj = JSON.stringify(model);
        var url = applicationBaseUrl +'/Claim/PolicyReactivation';
        var data = { policyno: model.policyno };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            toastr.success(resp, "Policy Reactivation");
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                //window.location.href = '/Login';
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    } else {
        HideLoading();
    }

}