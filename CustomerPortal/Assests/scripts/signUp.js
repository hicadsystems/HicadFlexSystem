var benficiaries = benficiaries || new Array();
var nok = nok || {};
var signUpModel = signUpModel || {};
var totalPropotion = totalPropotion || 0;
$('#btnstep1Next').click(function () {
    console.log('Submitting step 1');
    //ShowLoading();
    var isvalid = ValidateInput('#step1Frm')
    if (isvalid) {
        var PersonalInfo = $("#step1Frm").serializeObject();
        if (PersonalInfo != null || PersonalInfo != {} || PersonalInfo !== undefined) {
            var valUrl =applicationBaseUrl +  '/SignUp/Validate'
            ShowLoading();
            $.ajax({
                url: valUrl,
                type: "POST",
                data: { email: PersonalInfo.Email, phone: PersonalInfo.Phone },
                success: function (resp) {
                    console.log(resp);
                    if (!resp) {
                        toastr.error("Email/Phone already exists for a policy. Contact Admin for details", "User Details Already Exist");
                        HideLoading();
                        return;
                    }
                    else {
                        signUpModel.PersonalInfo = PersonalInfo;
                        console.log(signUpModel);
                        postSignUp(1);
                        HideLoading();
                    }
                },
                error: function (resp) {
                    HideLoading();
                    toastr.error(resp.statusText, "Error");
                    return;
                }
            });
        }
        else {
            toastr.error("An Error Occurred.Please refresh and try again", "Error");
            HideLoading();
        }
    }

});

$('#btnstep2Next').click(function () {
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
            postSignUp(2);
        }
        else {
            toastr.error("An Error Occurred.Please refresh and try again", "Error");
        }
    }
    HideLoading();
});

$('#btnstep2Back').click(function () {
    console.log('Back to step 1');
    ShowLoading();
    back(2);
    HideLoading();
});
$('#btnstep3Back').click(function () {
    console.log('Back to step 2');
    ShowLoading();
    back(3);
    HideLoading();
});

function postSignUp(step) {
    console.log("step :" + step);
    ShowLoading();
    var progress;
    var nStep;
    nStep = step + 1;
    progress = 100 / 3 * nStep;
    progress = progress + '%';
    var stepname;
    var show;
    var hide;
    switch (nStep) {
        case 2:
            stepname = "Step 2: Next of Kin Information";
            show = document.getElementById('divstep2');
            hide = document.getElementById('divstep1');
            break;
        case 3:
            stepname = "Step 3: Beneficiary Information";
            show = document.getElementById('divstep3');
            hide = document.getElementById('divstep2');
            break;
        default:
            break;
    }

    show.style.display = "block";
    hide.style.display = "none";
    var title = document.getElementById('stepTitle');
    title.innerText = stepname;
    $('#signUpProgess').attr('aria-valuenow', nStep).css('width', progress);
};

function back(step) {
    console.log("step :" + step);
    var progress;
    var nstep;
    nstep = step - 1;
    progress = 100 / 3 * nstep;
    progress = progress + '%';
    var stepname;
    var show;
    var hide;
    switch (nstep) {
        case 1:
            stepname = "Step 1: Personal Information";
            show = document.getElementById('divstep1');
            hide = document.getElementById('divstep2');
            break;
        case 2:
            stepname = "Step 2: Next of Kin Information";
            show = document.getElementById('divstep2');
            hide = document.getElementById('divstep3');
            break;
        default:
            break;
    }
    var title = document.getElementById('stepTitle');
    title.innerText = stepname;
    $('#signUpProgess').attr('aria-valuenow', nstep).css('width', progress);
    show.style.display = "block";
    hide.style.display = "none";

};

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
    row.insertCell(5).innerHTML = ben.Dob;
    row.insertCell(6).innerHTML = ben.Relationship;
    row.insertCell(7).innerHTML = ben.Proportion;
    HideLoading();
}

function deleteRow(obj) {
    ShowLoading();
    var index = obj.parentNode.parentNode.rowIndex;
    var table = document.getElementById("tbBen");
    table.deleteRow(index);
    var i = index - 1;
    var ben = benficiaries[i]
    totalPropotion = totalPropotion - ben.Proportion;
    benficiaries.splice(i, 1);
    HideLoading();
}

$('#btnaddBen').click(function () {
    ShowLoading();
    var isvallid = ValidateInput('#step3frm')
    if (isvallid) {
        var name = document.getElementById('benName').value;
        var address = document.getElementById('benAdd').value;
        var phone = document.getElementById('benPhone').value;
        var email = document.getElementById('benEmail').value;
        var dob = document.getElementById('benDob').value;
        var relationship = document.getElementById('benRelat').value;
        var proportion = document.getElementById('benProp').value;
        totalPropotion = (totalPropotion * 1) + (proportion * 1);
        if (proportion > 100 || totalPropotion > 100) {
            totalPropotion = totalPropotion - proportion;
            toastr.error("Total Proportion should not exceed 100%", "Validation Error");
            HideLoading()
            return;
        }

        var ben = { Name: name, Address: address, Phone: phone, Dob: dob, Relationship: relationship, Proportion: proportion, Email: email };

        benficiaries.push(ben);
        addRow(ben);
        clear();
    }
    HideLoading();
});

function clear() {
    document.getElementById('benName').value='';
    document.getElementById('benAdd').value='';
    document.getElementById('benPhone').value='';
    document.getElementById('benEmail').value='';
    document.getElementById('benDob').value='';
    document.getElementById('benRelat').value='';
    document.getElementById('benProp').value='';
}
$('#btnsubmit').click(function () {
    console.log('About to Save Sign Up');
    ShowLoading();
    if (benficiaries.length > 0) {
        if (signUpModel != null || signUpModel != {} || signUpModel !== undefined) {
            //var benJson = JSON.stringify(benficiaries).toString();
            //benficiaries.toString();
            signUpModel.PersonalInfo.Beneficiary = benficiaries;
            var url = $("#step3frm").attr("action");
            $.ajax({
                url: url,
                type: "POST",
                data: { signUpmodel: signUpModel },
                success: function (resp) {
                    window.location.href = resp;
                    HideLoading();
                },
                error: function (resp) {
                    console.log('Error Occurred: ' + resp);
                    toastr.error(resp.statusText, "SignUpError");
                    HideLoading();
                }
            });
        }
        else {
            toastr.error("Incomplete Form", "Error");
            HideLoading();
        }
    }
    else {
        toastr.error( "One or more beneiciary required","Error");
        HideLoading();
    }
});

function ShowLoading() {
    $('#ajax').modal({ backdrop: 'static', keyboard: false });
}

function HideLoading() {
    $('#ajax').modal('hide');
}
