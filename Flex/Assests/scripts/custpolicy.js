/// <reference path="custpolicy.js" />
var state = '';
var benficiaries = benficiaries || new Array();
var nok = nok || {};
var PersonalInfo = PersonalInfo || {};
/*var ben = ben || {};*/
var signUpModel = signUpModel || {};
var totalPropotion = totalPropotion || 0;

function retrievePendQuatations(el) {
    ShowLoading();
    console.log('about to get pending policy for approval');
    var datefrom = $("#txtdatefrom").val();
    var dateto = $("#txtdateto").val();
    var url = $(el).attr('data-url');
    $.ajax({
        url: url,
        type: "POST",
        data: { datefrom: datefrom, dateTo: dateto },
        success: function (data) {
            //$('#tbpPolicyContainer').html(data)
            var tbDiv = document.getElementById('tbpPolicyContainer');
            tbDiv.innerHTML = data;
            tbDiv.style.display = "block";

            HideLoading();
            //window.location.href = data;
        },
        error: function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        }
    });
};

function retrieveApprovedQuaotations (el,format) {
    ShowLoading();
    console.log('about to get approved proposal');
    var datefrom = $("#txtadatefrom").val();
    var dateto = $("#txtadateto").val();

    var download = false;
    if (format || format != null) {
        download = true;
    }

    var propQuery = propQuery || {};

    propQuery.DateFrom = datefrom;
    propQuery.DateTo = dateto;
    propQuery.IsReport = download;
    propQuery.ReportFormat = format;

    var url = $(el).attr('data-url');
    var activetab = $('.nav-tabs li .active');
    console.log(activetab);

    var data = { query: propQuery };
    var approvedProposalPromise = Post(url, data, 'Post');

    approvedProposalPromise.done(function (resp) {
        if (!download) {
            var tbDiv = document.getElementById('tbaPolicyContainer');
            tbDiv.innerHTML = resp;
            tbDiv.style.display = "block";
        }
        //window.open(resp, "resizeable,scrollbar");
        HideLoading();
    });

    approvedProposalPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });

};

function retrieveApprovedQuaotations2(el, format) {
    ShowLoading();
    console.log('about to get approved proposal');
    var datefrom = $("#txtadatefrom").val();
    var dateto = $("#txtadateto").val();

    var download = false;
    if (format || format != null) {
        download = true;
    }

    var propQuery = propQuery || {};

    propQuery.DateFrom = datefrom;
    propQuery.DateTo = dateto;
    propQuery.IsReport = download;
    propQuery.ReportFormat = format;

    var url = $(el).attr('data-url');
    

    var data = { query: propQuery };
    var approvedProposalPromise = Post(url, data, 'Post');

    approvedProposalPromise.done(function (resp) {
       
        window.open(resp, "resizeable,scrollbar");
        HideLoading();
    });

    approvedProposalPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
};


//$('#tbpPolicyContainer').on('click', '#selectAllChk', function () {
//    console.log(this);
//    if (this.checked) {
//        $('.checkbox').attr('checked', true);
//    } else {
//        $('.checkbox').attr('checked', false);
//    }
//   // $('.checkbox').attr('checked', this.checked);
//});

function togglecheckAll(el) {
    console.log(el);
    if (el.checked) {
        $('.checkbox').attr('checked', true);
    } else {
        $('.checkbox').attr('checked', false);
    }
};

function getChecked() {
    var checkedQuotes = checkedQuotes || new Array();
    var chkbox = document.getElementsByClassName('checkbox');
    for (var i = 0; i < chkbox.length; i++) {
        if (chkbox[i].checked) {
            checkedQuotes.push(chkbox[i].value);
        }
    }

    return checkedQuotes;
};


function approve(el) {
    ShowLoading();
    console.log('About to approve');
    var regnos = getChecked();
    var url = $(el).attr('data-url');
    if (regnos.length > 0) {
        var regNoJson = JSON.stringify(regnos).toString();
        $.ajax({
            url: url,
            type: "POST",
            data: { QuoteNos: regNoJson },
            success: function (data) {
                window.location.href = applicationBaseUrl + '/DashBoard';
                //toastr.success(data, "Approval")
                HideLoading();
            },
            error: function (resp) {
                if (resp.status === 401) {
                    window.location.href = loginurl;
                }
                toastr.error(resp.statusText, "Error");
                HideLoading();
            }
        });
    }
    else {
        toastr.error("Select one or more pending quotation(s) to approve", "Error");
        HideLoading();
    }
}

function disapprove(el) {
    ShowLoading();
    console.log('About to disapprove');
    var regnos = getChecked();
    var url = $(el).attr('data-url');
    if (regnos.length > 0) {
        var regNoJson = JSON.stringify(regnos).toString();
        $.ajax({
            url: url,
            type: "POST",
            data: { QuoteNos: regNoJson },
            success: function (data) {
                window.location.href = applicationBaseUrl + '/DashBoard';
                //toastr.success(data, "disapproved")
                HideLoading();
            },
            error: function (resp) {
                if (resp.status === 401) {
                    window.location.href = loginurl;
                }
                toastr.error(resp.statusText, "Error");
                HideLoading();
            }
        });
    }
    else {
        toastr.error("Select one or more pending quotation(s) to approve", "Error");
        HideLoading();
    }
}

function togglecheck(){
    if ($(".checkbox").length == $(".checkbox:checked").length) {
        $("#selectAllChk").attr("checked", "checked");
    } else {
        $("#selectAllChk").removeAttr("checked");
    }
}

$('.nav-tabs li a').click(function () {
    console.log(this);
    var ctrl = this;

    var tabName = ctrl.text;
    console.log(tabName);
    var pbtn = document.getElementById('btnppsearch');
    var hdProposal = document.getElementById('hdProposal');
    var url = '';
    var spApproval = document.getElementById('spApproval');
    if (tabName == 'Pending Proposal') {
        state = 'PendingProposal';
        spApproval.style.display = 'block';
    }
    if (tabName == 'Accepted Proposal')
    {
        state = 'AcceptedProposal';
        spApproval.style.display = 'none';
    }
});

function showresetPwd(el) {
    ShowLoading();
    console.log(id);

    var url = $(el).attr('data-url');
    var id = $(el).attr('data-id');
    var data = { Id: id};

    var resetpwdPromise = Post(url, data, 'Get');

    resetpwdPromise.done(function (resp) {
        HideLoading();
        showModal(resp,'Reset Password','resetPwd()')
    });

    resetpwdPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function resetPwd() {
    hideModal();
    ShowLoading();
    var id = document.getElementById('id').value;
    var data = {Id:id};
    var url =applicationBaseUrl + '/CustPolicy/PasswordReset';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        toastr.success(resp, 'Password Reset');
        alert(resp);
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error("An Error Occurred.", "Error");
        HideLoading();
    });
    //HideLoading();
};
function showaddpolicy(el) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var id = $(el).attr('data-id');
    var data = { Id: id };

    var addPolicyPromise = Post(url, data, 'Get');

    addPolicyPromise.done(function (resp) {
        HideLoading();
        showModal(resp, 'Add Policy', 'addPolicy()');
    });

    addPolicyPromise.fail(function (data) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function addPolicy() {
    hideModal();
    ShowLoading();
    var id = document.getElementById('Id').value;
    var policyno = document.getElementById('Policyno').value;
    if (id !="" && policyno != "") {
        var data = { Id: id, policyno: policyno };
        var url =applicationBaseUrl + '/CustPolicy/UpdatePolicy';

        var coyPromise = Post(url, data, 'Post');

        coyPromise.done(function (resp) {
            toastr.success(resp, 'Add Policy');
            window.location.href = applicationBaseUrl + '/DashBoard';
            HideLoading();
        });

        coyPromise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });

    }
    else {
        toastr.error("Please Enter Policy Number.", "Error");
        HideLoading();
    }
    //HideLoading();
};

function searchCustomer(term, page, size) {
    var spinner = document.getElementById('searching');
    spinner.style.display = 'block';
    var data = { searchterm: term, page: page, pagesize: size };
    var url =applicationBaseUrl + '/CustPolicy/SearchCustomer';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbcust');
        pagediv.innerHTML = resp;
        spinner.style.display = 'none';
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        spinner.style.display = 'none';
    });
}
function searchAgentPolicies(el, page) {
    ShowLoading();
 /*   alert("i am hereeee");*/
    var query = $("#frmSearch").serializeObject();
    var url = $(el).attr('data-url');
    if (page !== undefined || page !== '' || page !== 0) {
        var pageobj = {};
        pageobj.Page = page;

        query.Page = pageobj;
    }
    var data = { query: query };
    var transPromise = Post(url, data, 'Post');

    transPromise.done(function (resp) {
        ShowLoading();
        var tbDiv = document.getElementById('tbpolicy');
        tbDiv.innerHTML = resp;
        tbDiv.style.display = "block";
        HideLoading();
    });

    transPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function searchPayhist(el, page) {
    ShowLoading();
 /*   alert("i am hereeee");*/
    var query = $("#frmSearch").serializeObject();
    var url = $(el).attr('data-url');
    if (page !== undefined || page !== '' || page !== 0) {
        var pageobj = {};
        pageobj.Page = page;

        query.Page = pageobj;
    }
    var data = { query: query };
    var transPromise = Post(url, data, 'Post');

    transPromise.done(function (resp) {
        ShowLoading();
        var tbDiv = document.getElementById('tbpolicy');
        tbDiv.innerHTML = resp;
        tbDiv.style.display = "block";
        HideLoading();
    });

    transPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function searchPolicies(el, page) {
  /*  alert("i am hereeee");*/
    ShowLoading();

    var query = $("#frmSearch").serializeObject();
    var url = $(el).attr('data-url');
    if (page !== undefined || page !== '' || page !== 0) {
        var pageobj = {};
        pageobj.Page = page;

        query.Page = pageobj;
    }
    var data = { query: query };
    var transPromise = Post(url, data, 'Post');

    transPromise.done(function (resp) {
        ShowLoading();
        var tbDiv = document.getElementById('tbpolicy');
        tbDiv.innerHTML = resp;
        tbDiv.style.display = "block";
        HideLoading();
    });

    transPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function createPolicy(step) {
    switch (step) {
        case 1:
            processStep1();
            break;
        case 2:
            processStep2();
            break;
        case 3:
            savePolicy();
            break;
    }
}

function editPolicy(step) {
    switch (step) {
        case 1:
            editprocessStep1();
            break;
        case 2:
            editprocessStep2();
            break;
        case 3:
            updatePolicy();
            break;
    }
}

function processStep1() {
    console.log('Submitting step 1');
    ShowLoading();
    var isvalid = ValidateInput('#step1Frm');
    if (isvalid) {
        PersonalInfo = $("#step1Frm").serializeObject();
        if (PersonalInfo != null || PersonalInfo != {} || PersonalInfo !== undefined) {
            signUpModel.PersonalInfo = PersonalInfo;
            console.log(signUpModel);
            MoveNext(2);
        }
        else {
            toastr.error("An Error Occurred.Please refresh and try again", "Error");
        }
    }
    HideLoading();
}

function editprocessStep1() {
    console.log('Submitting step 1');
    ShowLoading();
    var isvalid = ValidateInput('#stepAFrm');
    if (isvalid) {
        PersonalInfo = $("#stepAFrm").serializeObject();
        if (PersonalInfo != null || PersonalInfo != {} || PersonalInfo !== undefined) {
            signUpModel.PersonalInfo = PersonalInfo;
            console.log(signUpModel);
            MoveNextEdit(2);
        }
        else {
            toastr.error("An Error Occurred.Please refresh and try again", "Error");
        }
    }
    HideLoading();
}

function processStep2() {
    console.log('Submitting step 2');
    ShowLoading();
    var isvalid = ValidateInput('#step2Frm')
    if (isvalid) {
        var form = $("#step2Frm");
        var nok = form.serializeObject();
        if (nok != null || nok != {} || nok !== undefined) {
            nok.Category = 1;
            signUpModel.PersonalInfo.NextofKin = nok;
            console.log(signUpModel);
            MoveNext(3);
        }
        else {
            toastr.error("An Error Occurred.Please refresh and try again", "Error");
        }
    }
    HideLoading();
}

function editprocessStep2() {

    console.log('About to Save Sign Up');
    ShowLoading();

    var isvalid = ValidateInput('#nok')
    if (isvalid) {
        var form = $("#nok");
        var nok = form.serializeObject();
        if (nok != null || nok != {} || nok !== undefined) {
            signUpModel.PersonalInfo = PersonalInfo;
            //nok.Category = 1;
            signUpModel.PersonalInfo.NextofKin = nok;
            console.log(signUpModel);
            //MoveNextEdit(3);
        }
        else {
            toastr.error("An Error Occurred.Please refresh and try again", "Error");
        }
    }
    else {
        return;
    }
    if (signUpModel != null || signUpModel != {} || signUpModel !== undefined) {
       
        var url = $("#nok").attr("action");
        var data = { signUpmodel: signUpModel }

        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            console.log(resp);
            MoveNextEdit(3);
            toastr.success(data, "Updated Successfully")
            //window.location.href = applicationBaseUrl + '/DashBoard';
            HideLoading();
            //var pagediv = document.getElementById('tbcust');
            //pagediv.innerHTML = resp;
            //spinner.style.display = 'none';
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
    HideLoading();
}

function addRow(ben) {
    ShowLoading();
    //var myName = document.getElementById("name");
    //var age = document.getElementById("age");
    var table = document.getElementById("tbBen");
    var tbDiv = document.getElementById('divBen');
    tbDiv.style.display = "block";

    var tbody = document.getElementById('tbBen').getElementsByTagName('tbody')[0];
    var rowCount = tbody.rows.length;
    var row = tbody.insertRow(rowCount);

    row.insertCell(0).innerHTML = '<input type="button" value = "Remove" onClick="Javacsript:deleteRow(this)">';
    row.insertCell(1).innerHTML = ben.Name;
    row.insertCell(2).innerHTML = ben.Address;
    row.insertCell(3).innerHTML = ben.Phone;
    row.insertCell(4).innerHTML = ben.Email;
    row.insertCell(5).innerHTML = ben.dob;
    row.insertCell(6).innerHTML = ben.Relationship;
    row.insertCell(7).innerHTML = ben.Proportion;
    HideLoading();
}

function addRowEdit(ben) {
    ShowLoading();
    //var myName = document.getElementById("name");
    //var age = document.getElementById("age");
    var table = document.getElementById("tbBenEdit");
    var tbDiv = document.getElementById('divBenEdit');
    tbDiv.style.display = "block";

    var tbody = document.getElementById('divBenEdit').getElementsByTagName('tbody')[0];
    var rowCount = tbody.rows.length;
    var row = tbody.insertRow(rowCount);

    row.insertCell(0).innerHTML = '<input type="button" value = "Remove" onClick="Javacsript:deleteRow(this)">';
    row.insertCell(1).innerHTML = ben.Name;
    row.insertCell(2).innerHTML = ben.Address;
    row.insertCell(3).innerHTML = ben.Phone;
    row.insertCell(4).innerHTML = ben.Email;
    row.insertCell(5).innerHTML = ben.dob;
    row.insertCell(6).innerHTML = ben.Relationship;
    row.insertCell(7).innerHTML = ben.Proportion;
    HideLoading();
}

function deleteRow(obj) {
    alert('About to delete')
    ShowLoading();
    var index = obj.parentNode.parentNode.rowIndex;
    var table = document.getElementById("tbBen");
    table.deleteRow(index);
    var i=index - 1;
    var ben = benficiaries[i]
    totalPropotion = totalPropotion - ben.Proportion;
    benficiaries.splice(i, 1);
    HideLoading();
}

function deleteRowEdit(obj) {
    ShowLoading();
    var index = obj.parentNode.parentNode.rowIndex;
    var table = document.getElementById("tbBenEdit");
    table.deleteRow(index);
    var i = index - 1;
    var ben = benficiaries[i]
    totalPropotion = totalPropotion - ben.Proportion;
    benficiaries.splice(i, 1);
    HideLoading();
}

function saveBeneficiary() {
    ShowLoading();
    var isvallid = ValidateInput('#step3frm')
    if (isvallid) {
        var form = $("#step3frm");
        var ben = form.serializeObject();
        var tPropotion = (totalPropotion * 1) + (ben.Proportion * 1);
        if (ben.Proportion > 100 || tPropotion > 100) {
            toastr.error("Total Proportion should not exceed 100%", "Validation Error");
            HideLoading()
            return;
        }
        totalPropotion = tPropotion;
        benficiaries.push(ben);
        addRow(ben);
        clear();
    }
    HideLoading();
}

function editBeneficiary(custId, benId) {

    console.log(id);
    var url = applicationBaseUrl + "/CustPolicy/GetBeneficiary";
    var data = { customerId: custId, benId: benId};
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        $("#editbenId").val(resp.PersonalInfo.Beneficiary[0].Id);
        $("#editbenName").val(resp.PersonalInfo.Beneficiary[0].Name);
        $("#editbenAdd").val(resp.PersonalInfo.Beneficiary[0].Address);
        $("#editbenEmail").val(resp.PersonalInfo.Beneficiary[0].Email);
        $("#editbenPhone").val(resp.PersonalInfo.Beneficiary[0].Phone);
        $("#editbenDob").val(resp.PersonalInfo.Beneficiary[0].Dob);
        $("#editbenRelat").val(resp.PersonalInfo.Beneficiary[0].Relationship);
        $("#editbenProp").val(resp.PersonalInfo.Beneficiary[0].Proportion);
        console.log(resp.PersonalInfo.Beneficiary[0]);
        //showModal(resp, 'Policy Details', '');
        //HideLoading();
        //showModal(resp, 'Policy Details', '');
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


function updateBeneficiary() {
    //console.log("Ok");
    alert("About to Add Beneficiary")
    ShowLoading();
    var isvallid = ValidateInput('#beneficiary')
    if (isvallid) {
        var form = $("#beneficiary");
        var ben = form.serializeObject();
        var tPropotion = (totalPropotion * 1) + (ben.Proportion * 1);
        if (ben.Proportion > 100 || tPropotion > 100) {
            toastr.error("Total Proportion should not exceed 100%", "Validation Error");
            HideLoading()
            return;
        }
        totalPropotion = tPropotion;
        benficiaries.push(ben);
        addRowEdit(ben);
        clear();
    }
    HideLoading();
}

function savePolicy () {
    console.log('About to Save Sign Up');
    ShowLoading();
    if (benficiaries.length > 0) {
        if (signUpModel != null || signUpModel != {} || signUpModel !== undefined) {
            //var benJson = JSON.stringify(benficiaries).toString();
            //benficiaries.toString();
            signUpModel.PersonalInfo.Beneficiary = benficiaries;
            var data= { signUpmodel: signUpModel }
            var url = $("#step3frm").attr("action");

            var Promise = Post(url, data, 'Post');

            Promise.done(function (resp) {
                console.log(resp);
                toastr.success(data, "Policy Creation")
                window.location.href = applicationBaseUrl + '/DashBoard';
                HideLoading();
                //var pagediv = document.getElementById('tbcust');
                //pagediv.innerHTML = resp;
                //spinner.style.display = 'none';
            });

            Promise.fail(function (resp) {
                if (resp.status === 401) {
                    window.location.href = loginurl;
                }
                toastr.error(resp.statusText, "Error");
                HideLoading();
            });
        }
        else {
            toastr.error("Incomplete Form", "Error");
            HideLoading();
        }
    }
    else {
        toastr.error("One or more beneiciary required", "Error");
        HideLoading();
    }
}

function updatePolicy() {
    console.log('About to Update beneficiary.');

    var isvalid = ValidateInput('#beneficiary');
    console.log(isvalid);
    if (isvalid) {
        
        signUpModel.PersonalInfo = {};

        var form = $("#beneficiary");
        var ben = form.serializeObject();

        if (benficiaries.length > 0) {
            signUpModel.PersonalInfo.Beneficiary = benficiaries;
            console.log(signUpModel);
        }
        else if (ben != null || ben != {} || ben !== undefined) {
            //ben.Category = 1;
            signUpModel.PersonalInfo.Benefitiary = ben;
            console.log(signUpModel);
            //MoveNextEdit(3);
        }
        else{
            toastr.error("An Error Occurred.Please refresh and try again", "Error");
        }
    }
    else {
        return;
    }
    if (signUpModel != null || signUpModel != {} || signUpModel !== undefined) {

        var url = $("#beneficiary").attr("action");
        var data = { signUpmodel: signUpModel }

        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            console.log(resp);
           // MoveNextEdit(3);
            toastr.success(data, "Updated Successfully")
            window.location.href = applicationBaseUrl + '/DashBoard';
            HideLoading();
            //var pagediv = document.getElementById('tbcust');
            //pagediv.innerHTML = resp;
            //spinner.style.display = 'none';
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
    HideLoading();

    console.log('About to Save Sign Up');
    ShowLoading();

    /*if (benficiaries.length > 0) {
        if (signUpModel != null || signUpModel != {} || signUpModel !== undefined) {
            //var benJson = JSON.stringify(benficiaries).toString();
            //benficiaries.toString();
            signUpModel.PersonalInfo.Beneficiary = benficiaries;
            var data = { signUpmodel: signUpModel }
            var url = $("#beneficiary").attr("action");

            var Promise = Post(url, data, 'Post');

            Promise.done(function (resp) {
                console.log("error");
                console.log(resp);
                toastr.success(data, "Policy Creation")
                window.location.href = applicationBaseUrl + '/DashBoard';
                HideLoading();
                //var pagediv = document.getElementById('tbcust');
                //pagediv.innerHTML = resp;
                //spinner.style.display = 'none';
            });

            Promise.fail(function (resp) {
                if (resp.status === 401) {
                    window.location.href = loginurl;
                }
                toastr.error(resp.statusText, "Error");
                HideLoading();
            });
        }
        else {
            toastr.error("Incomplete Form", "Error");
            HideLoading();
        }*/
    //}
    //else {
    //    toastr.error("One or more beneficiary required", "Error");
    //    HideLoading();
    //}
}

function clear() {
    document.getElementById('benName').value = '';
    document.getElementById('benAdd').value = '';
    document.getElementById('benPhone').value = '';
    document.getElementById('benEmail').value = '';
    document.getElementById('benDob').value = '';
    document.getElementById('benRelat').value = '';
    document.getElementById('benProp').value = '';
}

function MoveNext(step) {
    var show;
    var hide;

    switch (step) {
        case 2:
            show = document.getElementById('divstep2');
            hide = document.getElementById('divstep1');
            break;
        case 3:
            show = document.getElementById('divstep3');
            hide = document.getElementById('divstep2');
            break;
        default:
            break;
    }

    show.style.display = "block";
    hide.style.display = "none";
}

function MoveNextEdit(step) {
    var show;
    var hide;

    switch (step) {
        case 2:
            show = document.getElementById('divnok');
            hide = document.getElementById('divpDetails');
            break;
        case 3:
            show = document.getElementById('divben');
            hide = document.getElementById('divnok');
            break;
        default:
            break;
    }

    show.style.display = "block";
    hide.style.display = "none";
}

function moveBack(step) {
    var show;
    var hide;
    switch (step) {
        case 1:
            show = document.getElementById('divstep1');
            hide = document.getElementById('divstep2');
            break;
        case 2:
            show = document.getElementById('divstep2');
            hide = document.getElementById('divstep3');
            break;
        default:
            break;
    }
    show.style.display = "block";
    hide.style.display = "none";
}

function moveBackEdit(step) {
    var show;
    var hide;
    switch (step) {
        case 1:
            show = document.getElementById('divpDetails');
            hide = document.getElementById('divnok');
            break;
        case 2:
            show = document.getElementById('divnok');
            hide = document.getElementById('divben');
            break;
        default:
            break;
    }
    show.style.display = "block";
    hide.style.display = "none";
}

function showpolicyDetails(Id) {
    ShowLoading();
    var url = applicationBaseUrl + "/CustPolicy/ViewPolicy";
    var data = { Id: Id };
    var Promise = Post(url, data, 'Post');

    Promise.done(function (resp) {
        HideLoading();
        showModal(resp, 'Policy Details', '');
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

function toggleManagePolicy(value) {
    var divpDetails = document.getElementById('divpDetails');
    var divNOK = document.getElementById('divnok');
    var divBen = document.getElementById('divben');
    if (value == 'pDetails') {
        divpDetails.style.display = 'block';
        divNOK.style.display = 'none';
        divBen.style.display = 'none';
    }
    else if (value == 'NOK') {
        divpDetails.style.display = 'none';
        divNOK.style.display = 'block';
        divBen.style.display = 'none';
    }
    else if (value == 'Ben') {
        divpDetails.style.display = 'none';
        divNOK.style.display = 'none';
        divBen.style.display = 'block';
    }
}

function uploadPic(el) {
    ShowLoading();
    var input = document.getElementById('pictureUpload');
    var picture = input.files[0];
    if (picture.length === 0)
    {
        toastr.error("Select a picture to upload", 'Picture Upload');
    }

    var url = $(el).attr('data-url');
    var data = new FormData();
    if (window.FormData !== undefined) {
        data.append("Picture", picture);

        $.ajax({
            type: "POST",
            url: url,
            contentType: false,
            processData: false,
            data: data,
            success: function (result) {
                console.log(result);
                //$("#picture").attr("src", result.Url);
                $("#picture").attr('src', 'data:image/jpg;base64,'+result.Url);
                $("#PictureFile").val(result.FileName);
                $("#picture").load();
                HideLoading();
            },
            error: function (xhr, status, p3, p4) {
                var err = "Error " + " " + status + " " + p3 + " " + p4;
                if (xhr.responseText && xhr.responseText[0] == "{")
                    err = JSON.parse(xhr.responseText).Message;
                console.log(err);
                HideLoading();
            }
        });
    } else {
        alert("This browser doesn't support HTML5 file uploads!");
    }
}

function uploadPolicy(el) {
    ShowLoading();
    var input = document.getElementById('polUpload');
    var policy = input.files[0];
    if (picture.length === 0) {
        toastr.error("Select an excel File to upload", 'Policy Upload');
    }

    var url = $(el).attr('data-url');
    var data = new FormData();
    if (window.FormData !== undefined) {
        data.append("Policy", policy);

        var grpCode = $('#grpcode').val();
        var polType = $('#poltype').val();
        data.append("GroupCode", grpCode);
        data.append("PolicyType", polType);

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
                toastr.success("Polciy Uploaded Successfully", 'Policy Upload');
                console.log(result);
                HideLoading();
                window.location.reload();
            },
            error: function (xhr, status, p3, p4) {
                var err = "Error " + " " + status + " " + p3 + " " + p4;
                if (xhr.responseText && xhr.responseText[0] == "{")
                    err = JSON.parse(xhr.responseText).Message;

                console.log(err);
                toastr.error(err, 'Policy Upload');
                HideLoading();
            }
        });
    } else {
        alert("This browser doesn't support HTML5 file uploads!");
    }
}

function showpolicy(el) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var id = $(el).attr('data-id');
    var data = { CustomerId: id };

    var addPolicyPromise = Post(url, data, 'Get');

    addPolicyPromise.done(function (resp) {
        HideLoading();
        showModal(resp, 'View Policies', '');
    });

    addPolicyPromise.fail(function (data) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}
