function showClaim(el) {
    console.log('About to add Claim');
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'saveClaim()';
        showModal(resp, 'Claim Request', func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    //HideLoading();
};

function showAmount(el) {
    console.log(el);
    var amtdiv = document.getElementById('divamt');
    if (el.value==0) {
        amtdiv.style.display = 'block';
    }
    else {
        amtdiv.style.display = 'none';
    }
}

function saveClaim() {
    console.log('about to save claim');
    ShowLoading();
    hideModal();
    var isvalid = ValidateInput('#claim')
    if (isvalid) {
        var model = $("#claim").serializeObject();
        var queryj = JSON.stringify(model);
        var url = applicationBaseUrl + '/Claim/Save';
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            var pagediv = document.getElementById('divcontent');
            pagediv.innerHTML = resp;
            //toastr.success(resp, "Claim Request");
            HideLoading();
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
    else {
        HideLoading();
    }

}


function searchClaim() {
    ShowLoading();
    var sDate = document.getElementById('txtdatefrom').value;
    var eDate = document.getElementById('txtdateto').value;

    var url = applicationBaseUrl + '/Claim/SearchClaim';

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
            window.location.href = loginurl;;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });

}

function cancelClaim(id) {
    var cancel= getConfirmation();
    if (cancel) {
        console.log('Cancel Claim');
    }
    hideModal();
    ShowLoading();
    var url = applicationBaseUrl + '/Claim/CancelClaim';
    var data = { Id: id };
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        var pagediv = document.getElementById('divcontent');
        pagediv.innerHTML = resp;
        //toastr.success(resp, "Claim Request");
        HideLoading();
    });

    Promise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function getConfirmation() {
    var retVal = confirm("Do you want to Cancel Claim?");
    if (retVal == true) {
        return true;
    }
    else {
        return false;
    }

    
}
