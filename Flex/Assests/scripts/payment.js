var transQuery = transQuery || {};

function searchTransaction(el) {
    ShowLoading();
    console.log('Inside transaction search');

    transQuery.DateFrom = document.getElementById('DateFrom').value;
    transQuery.DateTo = document.getElementById('DateTo').value;
    //transQuery.Instrument = document.getElementById('Instrument').value;
    //transQuery.Location = document.getElementById('Location').value;
    transQuery.policyno = document.getElementById('PolicyNo').value;
    //transQuery.PaymentMethod = document.getElementById('PaymentMethod').value;
    transQuery.ReceiptNo = document.getElementById('RecieptNo').value;

    var jsonData = JSON.stringify(transQuery).toString();
    var url = $(el).attr('data-url');
    var data = { queryjson: jsonData };
    var transPromise = Post(url, data, 'Get');
    
    transPromise.done(function (resp) {
        ShowLoading();
        var tbDiv = document.getElementById('tbtrans');
        tbDiv.innerHTML = resp;
        tbDiv.style.display = "block";
        HideLoading();
    });

    transPromise.fail(function (resp) {
        ShowLoading();
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    //HideLoading();
}

function searchGTransaction(el) {
    ShowLoading();
    console.log('Inside transaction search');

    transQuery.DateFrom = document.getElementById('gDateFrom').value;
    transQuery.DateTo = document.getElementById('gDateTo').value;
    transQuery.GroupCode = document.getElementById('grpcode').value;
    transQuery.ReceiptNo = document.getElementById('gRecieptNo').value;

    var jsonData = JSON.stringify(transQuery).toString();
    var url = $(el).attr('data-url');
    var data = { queryjson: jsonData };
    var transPromise = Post(url, data, 'Get');

    transPromise.done(function (resp) {
        ShowLoading();
        var tbDiv = document.getElementById('tbtrans');
        tbDiv.innerHTML = resp;
        tbDiv.style.display = "block";
        HideLoading();
    });

    transPromise.fail(function (resp) {
        ShowLoading();
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    //HideLoading();
}


function showPaymetSetUpInput(el, Id) {
    console.log('About to add/Edit Payment Account');
    ShowLoading();
        var url = $(el).attr('data-url');
        var data = { Id: Id };
        var coyProfilePromise = Post(url, data, 'Get');

        coyProfilePromise.done(function (resp) {
            //console.log(resp);
            var func = 'saveUpdatePayAcct()';
            showModal(resp, 'Setup Payment Account', func);
            jQuery(document).trigger("select2");
            HideLoading();
        });

        coyProfilePromise.fail(function (resp) {
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    //HideLoading();
};

function saveUpdatePayAcct() {
    console.log('about to save/update Poicy Type');
    hideModal();
    ShowLoading();
    var Isvalid = ValidateInput('#payAccts');

    if (Isvalid) {

        var bankLedger = document.getElementById('Bank').value;
        var incomeledger = document.getElementById('Income').value;
        if (bankLedger != incomeledger) {
            var formdata = $("form").serialize();

            var url =applicationBaseUrl + '/Payment/SaveUpdatePaymentAccount';

            var coyPromise = Post(url, formdata, 'Post');

            coyPromise.done(function (resp) {
                var pageview = document.getElementById('custpolContent');
                pageview.innerHTML = resp;
                HideLoading();
            });

            coyPromise.fail(function (resp) {
                toastr.error(resp.statusText, "Error");
                HideLoading();
            });
        }
        else {
            toastr.error("Bank Ledger should not be the same with income ledger", "Error");
            HideLoading();
        }
        

    }
    else {
            HideLoading();
    }
    //

}

function loadPolicyType(el) {
    var paymenthod = el.value;
    var data = { paymentMethod: paymenthod };
    var ddlpoltype = document.getElementById('PolicyType');
    var url = applicationBaseUrl + '/Payment/GetPolicyTypeNotSetUp'
    LoadDropDown(ddlpoltype, url, data, 'Select...');
}

function loadPaymentMethods(el) {
    //var ddlpaymethod = document.getElementById('PaymentMethod');
    LoadDropDown(el, '/Base/GetPaymentMethods', {}, 'Select...');

}

function toggleChqNo(el) {
    var paymethod = el.value;
    var chqdiv = document.getElementById('chqno');
    if (paymethod==1) {
        chqdiv.style.display = "block";
    } else {
        chqdiv.style.display = "none";
    }
}

function submitTransaction() {
    console.log('about to post transaction');
    ShowLoading();
    var frm = $("form");
    var formdata = frm.serialize();
    var url = frm.attr("action");

    var postTransPromise = Post(url, formdata, 'Post');

    postTransPromise.done(function (resp) {
        var type = document.getElementById('Type').value;
        if (type==0) {
            window.open(resp, "resizeable,scrollbar");
            //window.
        }
        else {
            var pageview = document.getElementById('custpolContent');
            pageview.innerHTML = resp;
        }
        HideLoading();
    });

    postTransPromise.fail(function (resp) {
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
   // HideLoading();


}

function gUpdateTransaction() {
    console.log('about to update transaction');
    ShowLoading();

    var frm = $("form");
    var query = frm.serializeObject();
    var queryj = JSON.stringify(query);
    var url = applicationBaseUrl + "/Payment/GUpdateTransactions";
    var data = { queryj: queryj };
    //var formdata = frm.serialize();
    //var url = frm.attr("action");

    var postTransPromise = Post(url, data, 'Post');

    postTransPromise.done(function (resp) {
        //var pageview = document.getElementById('custpolContent');
        //pageview.innerHTML = resp;
        toastr.success(resp, "Payment Update");
        window.location.reload();
        HideLoading();
    });

    postTransPromise.fail(function (resp) {
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    // HideLoading();


}
function updateTransaction() {
    console.log('about to update transaction');
    ShowLoading();

    var frm = $("form");
    //var query = frm.serializeObject();
   // var queryj = JSON.stringify(query);
    var url = applicationBaseUrl + "/Payment/UpdateTransactions";
    var formdata = frm.serialize();
    var url = frm.attr("action");
    //var data = { formdata: formdata };

    var postTransPromise = Post(url, formdata, 'Post');

    postTransPromise.done(function (resp) {
        //var pageview = document.getElementById('custpolContent');
        //pageview.innerHTML = resp;
        toastr.success(resp, "Payment Update");
        window.location.reload();
        HideLoading();
    });

    postTransPromise.fail(function (resp) {
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    // HideLoading();


}
function reverseTransaction() {
    console.log('about to reverse transaction');
    ShowLoading();

    var frm = $("form");
    var query = frm.serializeObject();
    var queryj = JSON.stringify(query);
    var url = applicationBaseUrl + "/Payment/GReverseTransactions";
    var data = { queryj: queryj };
    //var formdata = frm.serialize();
    //var url = frm.attr("action");

    var postTransPromise = Post(url, data, 'Post');

    postTransPromise.done(function (resp) {
        //var pageview = document.getElementById('custpolContent');
        //pageview.innerHTML = resp;
        toastr.success(resp, "Payment Update");
        window.location.reload();
        HideLoading();
    });

    postTransPromise.fail(function (resp) {
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    // HideLoading();


}


function searchPaymentAccount(el) {
    ShowLoading();
    var payAcctQuery = $("#frmSearch").serializeObject();
    var url = $(el).attr('data-url');
    var data = { querymodel: payAcctQuery };
    var transPromise = Post(url, data, 'Post');

    transPromise.done(function (resp) {
        ShowLoading();
        var tbDiv = document.getElementById('tbtrans');
        tbDiv.innerHTML = resp;
        tbDiv.style.display = "block";
        HideLoading();
    });

    transPromise.fail(function (resp) {
        ShowLoading();
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function validateReceipt(el) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var receiptNo = $(el).val();
    url = url + '?ReceiptNo=' + receiptNo;

    var transPromise = Post(url, null, 'Get');

    transPromise.done(function (resp) {
        console.log(resp);
        if (resp.success === true) {
            //$('#btnUpload').prop('disabled', false);
            $('#btnUpload').attr("disabled", false);
        }
        else {
            $('#btnUpload').attr("disabled", true);
            toastr.error(resp.message, "Error");
        }
        HideLoading();
    });

    transPromise.fail(function (resp) {
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function uploadPayment(el) {
    ShowLoading();
    var input = document.getElementById('payUpload');
    var payment = input.files[0];
    if (payment.length === 0) {
        toastr.error("Select an excel File to upload", 'Payment Upload');
    }

    var url = $(el).attr('data-url');
    var data = new FormData();
    if (window.FormData !== undefined) {
        data.append("Payment", payment);

        var grpCode = $('#grpcode').val();
        var receiptNo = $('#receiptno').val();
        var transDate = $('#transDate').val();

        data.append("GroupCode", grpCode);
        data.append("ReceiptNo", receiptNo);
        data.append("TransactionDate", transDate);

        $.ajax({
            beforeSend: function (xhr) {
                xhr.setRequestHeader('authToken', getAuthToken());
            },
            type: "POST",
            url: url,
            contentType: false,
            processData: false,
            data: data,
            success: function (result) {
                toastr.success("Payment Uploaded Successfully", 'Payment Upload');
                console.log(result);
                HideLoading();
                window.location.reload();
            },
            error: function (xhr, status, p3, p4) {
                var err = "Error " + " " + status + " " + p3 + " " + p4;
                if (xhr.responseText && xhr.responseText[0] == "{")
                    err = JSON.parse(xhr.responseText).Message;

                console.log(err);
                toastr.error(err, 'Payment Upload');
                HideLoading();
            }
        });
    } else {
        alert("This browser doesn't support HTML5 file uploads!");
    }
}

function showpaymentDetails(el) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var Promise = Post(url, null, 'Get');

    Promise.done(function (resp) {
        HideLoading();
        showModal(resp, 'Payment Details', '');
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

function updatepayment(el) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var Promise = Post(url, null, 'Get');

    Promise.done(function (resp) {
        HideLoading();
        showModal(resp, 'Update Payment', '');
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
/*
function exportPayment(format) {
    ShowLoading();
    var downloadModel = downloadModel || {};

    downloadModel.IsReport = true;
    downloadModel.ReportFormat = format;

    var data = { query: downloadModel };

    var url = applicationBaseUrl + '/Payment/PaymentListingPdf';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        window.open(resp, "resizeable,scrollbar");
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        HideLoading()
        toastr.error(resp.statusText, "Error");
    });
}
*/

function exportPayment(el) {
    ShowLoading();
    //console.log('Inside transaction search');

    transQuery.DateFrom = document.getElementById('DateFrom').value;
    transQuery.DateTo = document.getElementById('DateTo').value;
    transQuery.policyno = document.getElementById('PolicyNo').value;
    transQuery.RecieptNo = document.getElementById('RecieptNo').value;
    

    var jsonData = JSON.stringify(transQuery).toString();
    var url = $(el).attr('data-url');
    var data = { queryjson: jsonData };
    var transPromise = Post(url, data, 'Get');

    transPromise.done(function (resp) {
        window.open(resp, "resizeable,scrollbar");
        HideLoading();
    });

    transPromise.fail(function (resp) {
        HideLoading()
        toastr.error(resp.statusText, "Error");
    });
    //HideLoading();
}

/*
function exportPayment(format) {
    ShowLoading();
    var isvallid = format;
    if (isvallid) {
        var form = format;
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + '/Payment/PaymentListingPdf';
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
}*/

function exportPaymentXls(format) {
    ShowLoading();
    var downloadModel = downloadModel || {};

    downloadModel.IsReport = true;
    downloadModel.ReportFormat = format;

    var data = { query: downloadModel };

    var url = applicationBaseUrl + '/Payment/DownloadExcel';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        alert("Ok");
        window.open(resp, "resizeable,scrollbar");
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        HideLoading()
        toastr.error(resp.statusText, "Error");
    });
}

function ShowLoading() {
    $('#ajax').modal({ backdrop: 'static', keyboard: false });
}

function HideLoading() {
    $('#ajax').modal('hide');
}

function backupData() {
    ShowLoading();
    var url = applicationBaseUrl + "/Payment/BackupBeforeInterestCal"
    //var data = { queryj: queryj };
    var Promise = Post(url, 'Post');
    //document.getElementById('bkforintrcalc').disabled = false;

    Promise.done(function (resp) {
        HideLoading();
        document.getElementById('bkforintrcalc').disabled = true;
        document.getElementById('calcintr').disabled = false;

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

function calculateintr() {
    ShowLoading();
    var isvalid = ValidateInput('#calculateInterest');

    if (isvalid) {
        var form = $("#calculateInterest");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + "/Payment/CalculateInterest"
         var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            document.getElementById('bkforintrcalc').disabled = true;
            document.getElementById('calcintr').disabled = true;
            document.getElementById('restorebk').disabled = false;

            toastr.success("Interest Calculated Successfully", 'Interest Calculation');
            //window.open(resp, "resizeable,scrollbar")

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


function calculateintrTSP() {
    ShowLoading();
    var isvalid = ValidateInput('#calculateInterestTSP');

    if (isvalid) {
        var form = $("#calculateInterestTSP");
        var query = form.serializeObject();
        var queryj = JSON.stringify(query);
        var url = applicationBaseUrl + "/Payment/CalculateInterestTSP"
        var data = { queryj: queryj };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            HideLoading();
            document.getElementById('bkforintrcalc').disabled = true;
            document.getElementById('calcintr').disabled = true;
            document.getElementById('restorebk').disabled = false;

            toastr.success("Interest Calculated Successfully", 'Interest Calculation');
            //window.open(resp, "resizeable,scrollbar")

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
function restorebackup() {
    ShowLoading();
    var url = applicationBaseUrl + "/Payment/RestoreBackupAfterInterestCalc"
    //var data = { queryj: queryj };
    var Promise = Post(url, 'Post');
    //document.getElementById('bkforintrcalc').disabled = false;

    Promise.done(function (resp) {
        HideLoading();
        document.getElementById('bkforintrcalc').disabled = true;
        document.getElementById('calcintr').disabled = false;

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

