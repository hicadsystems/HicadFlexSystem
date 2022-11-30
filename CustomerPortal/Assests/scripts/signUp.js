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
            
           // var valUrl =applicationBaseUrl +  '/SignUp/Validate'
           // ShowLoading();
            //$.ajax({
            //    url: valUrl,
            //    type: "POST",
            //    data: { phone: PersonalInfo.Phone },
            //    success: function (resp) {
            //        if (!resp) {
            //            toastr.error("Phone already exists for a policy. Contact Admin for details", "User Details Already Exist");
            //            HideLoading();
            //            return;
            //        }
            //        else {
            //            var pt5 = PersonalInfo.PolicyType;
            //            var duu = PersonalInfo.Duration;
            //            if (duu < 5 && pt5==8) {
            //                alert(pt5);
            //                toastr.error("Contribution Duration can not be less than 5 (five)");
            //                HideLoading();
            //                return;
            //            } else {
            //                signUpModel.PersonalInfo = PersonalInfo;
            //                console.log(signUpModel);
            //                postSignUp(1, signUpModel);
            //                HideLoading();
            //            }
            //        }
            //    },
            //    error: function (resp) {
            //        HideLoading();
            //        toastr.error(resp.statusText, "Error");
            //        return;
            //    }
            //});

            var pt5 = PersonalInfo.PolicyType;
            var duu = PersonalInfo.Duration;
            if (duu < 5 && pt5 == 8) {
                alert(pt5);
                toastr.error("Contribution Duration can not be less than 5 (five)");
                HideLoading();
                return;
            } else {
                signUpModel.PersonalInfo = PersonalInfo;
                console.log(signUpModel);
                postSignUp(1, signUpModel);
                HideLoading();
            }
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
            postSignUp(2, signUpModel);
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
$('#btnstep4Back').click(function () {
    console.log('Back to step 3');
    ShowLoading();
    back(4);
    HideLoading();
});
function postSignUp(step, signUpModel) {
    console.log("step :" + step);
    ShowLoading();
    var progress;
    var nStep;
    nStep = step + 1;
    progress = 100 / 4 * nStep;
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
        case 4:
            stepname = "Step 4: Preview Information";
            show = document.getElementById('divstep4');

            var uploadfile = $("#PictureFile").get(0);
            var files = uploadfile.files;
            const [file] = files
            if (file) {
                blah.src = URL.createObjectURL(file)
            }

            document.getElementById("Surname").innerHTML = signUpModel.PersonalInfo.Surname;
            document.getElementById("OtherName").innerHTML = signUpModel.PersonalInfo.OtherNames;
            let dob = signUpModel.PersonalInfo.Dob;
            document.getElementById("DateBirth").innerHTML = dob;
            document.getElementById("ResidentialAddress").innerHTML = signUpModel.PersonalInfo.ResidentialAddress;
            document.getElementById("agentcode").innerHTML = signUpModel.PersonalInfo.agentcode;
            document.getElementById("Phone").innerHTML = signUpModel.PersonalInfo.Phone;
            document.getElementById("PostalAddress").innerHTML = signUpModel.PersonalInfo.PostalAddress;
            document.getElementById("OfficeAddress").innerHTML = signUpModel.PersonalInfo.OfficeAddress;
            document.getElementById("Occupation").innerHTML = signUpModel.PersonalInfo.Occupation;
            document.getElementById("IdentityType").innerHTML = signUpModel.PersonalInfo.IdentityType;
            document.getElementById("IdentityNumber").innerHTML = signUpModel.PersonalInfo.IdentityNumber;
            document.getElementById("Duration").innerHTML = signUpModel.PersonalInfo.Duration;
            document.getElementById("Email").innerHTML = signUpModel.PersonalInfo.Email;
            var dura = signUpModel.PersonalInfo.Frequency;
            if (dura == 1)
                document.getElementById("Frequency").innerHTML = "Monthly";
           else if (dura == 2)
                document.getElementById("Frequency").innerHTML = "Quaterly";
           else if (dura == 3)
                document.getElementById("Frequency").innerHTML = "Bi-Annually ";
          else if (dura == 4)
                document.getElementById("Frequency").innerHTML = "Annually";


            let amt = signUpModel.PersonalInfo.Amount;
            document.getElementById("Amount").innerHTML = amt;
            var polid = signUpModel.PersonalInfo.PolicyType;
            if (polid == 2)
                document.getElementById("PolicyType").innerHTML = "TARGET SAVING PLAN"
            else if (polid == 3)
                document.getElementById("PolicyType").innerHTML = "GRATUITY"
            else if (polid == 4)
                document.getElementById("PolicyType").innerHTML = "ALMOND FUND"
            else 
                document.getElementById("PolicyType").innerHTML = "PPP 2 FIVE YEAR PLAN"

            var locid = signUpModel.PersonalInfo.Locationid;
            if (locid == 1)
                document.getElementById("Location").innerHTML = "ABAKALIKI"
            else if (locid == 2)
                document.getElementById("Location").innerHTML = "ABEOKUTA"
            else if (locid ==3)
                document.getElementById("Location").innerHTML = "ABUJA"
            else if (locid == 4)
                document.getElementById("Location").innerHTML = "ADO - EKITI"
            else if (locid == 5)
                document.getElementById("Location").innerHTML = "AKURE"
            else if (locid == 6)
                document.getElementById("Location").innerHTML = "ASABA"
            else if (locid == 7)
                document.getElementById("Location").innerHTML = "AWKA"
            else if (locid == 8)
                document.getElementById("Location").innerHTML = "BAUCHI"
            else if (locid == 9)
                document.getElementById("Location").innerHTML = "BENIN - CITY"
            else if (locid == 10)
                document.getElementById("Location").innerHTML = "BIRNIN KEBBI"
            else if (locid == 11)
                document.getElementById("Location").innerHTML = "CALABAR"
            else if (locid == 12)
                document.getElementById("Location").innerHTML = "DAMATURU"
            else if (locid == 13)
                document.getElementById("Location").innerHTML = "DUTSE"
            else if (locid == 14)
                document.getElementById("Location").innerHTML = "ENUGUN"
            else if (locid == 15)
                document.getElementById("Location").innerHTML = "GOMBE"
            else if (locid == 16)
                document.getElementById("Location").innerHTML = "GUASAU"
            else if (locid == 17)
                document.getElementById("Location").innerHTML = "IBADAN"
            else if (locid == 18)
                document.getElementById("Location").innerHTML = "ILORIN"
            else if (locid == 19)
                document.getElementById("Location").innerHTML = "JALINGO"
            else if (locid == 20)
                document.getElementById("Location").innerHTML = "JOS"
            else if (locid == 21)
                document.getElementById("Location").innerHTML = "KADUNA"
            else if (locid == 22)
                document.getElementById("Location").innerHTML = "KANO"
            else if (locid == 23)
                document.getElementById("Location").innerHTML = "KASTINA"
            else if (locid == 24)
                document.getElementById("Location").innerHTML = "LAFIA"
            else if (locid == 25)
                document.getElementById("Location").innerHTML = "LAGOS"
            else if (locid == 26)
                document.getElementById("Location").innerHTML = "LOKOJA"
            else if (locid == 27)
                document.getElementById("Location").innerHTML = "MAIDUGURI"

            else if (locid == 28)
                document.getElementById("Location").innerHTML = "MAKURDI"
            else if (locid == 29)
                document.getElementById("Location").innerHTML = "MINNA"
            else if (locid == 30)
                document.getElementById("Location").innerHTML = "OSHOGBO"
            else if (locid == 31)
                document.getElementById("Location").innerHTML = "OWERRI"
            else if (locid == 32)
                document.getElementById("Location").innerHTML = "PORT - HARCOURT"
            else if (locid == 33)
                document.getElementById("Location").innerHTML = "SOKOTO"
            else if (locid == 34)
                document.getElementById("Location").innerHTML = "UMUAHIA"
            else if (locid == 35)
                document.getElementById("Location").innerHTML = "UYO"
            else if (locid == 36)
                document.getElementById("Location").innerHTML = "YENAGOA"
            else
                document.getElementById("Location").innerHTML = "YOLA"

            //document.getElementById("Location").innerHTML = getLocation(locationid);
            //document.getElementById("Locationid").innerHTML = locationid;
            document.getElementById("nokName").innerHTML = signUpModel.PersonalInfo.NextofKin.Name;
            document.getElementById("nokEmail").innerHTML = signUpModel.PersonalInfo.NextofKin.Email;
            document.getElementById("nokAddress").innerHTML = signUpModel.PersonalInfo.NextofKin.Address;
            document.getElementById("nokPhone").innerHTML = signUpModel.PersonalInfo.NextofKin.Phone;


            var name = signUpModel.PersonalInfo.Beneficiary[0].Name;
            var address = signUpModel.PersonalInfo.Beneficiary[0].Address;
            var phone = signUpModel.PersonalInfo.Beneficiary[0].phone;
            var email = signUpModel.PersonalInfo.Beneficiary[0].Email;
            var dob2 = signUpModel.PersonalInfo.Beneficiary[0].Dob;
            var relationship = signUpModel.PersonalInfo.Beneficiary[0].Relationship;
            var proportion = signUpModel.PersonalInfo.Beneficiary[0].Proportion;
            if (relationship == 0) {
                console.log(relationship)
                relationship = "Mother"
            }
            else if (relationship == 1) {
                relationship = "Father"
            }
            else if (relationship == 2) {
                relationship = "Daughther"
            }
            else if (relationship == 3) {
                relationship = "Son"
            }
            else if (relationship == 4) {
                relationship = "Brother"
            }
            else if (relationship == 5) {
                relationship = "Sister"
            }
            else if (relationship == 6) {
                relationship = "Husband"
            }
            else if (relationship == 7) {
                relationship = "Wife"
            }
            else {
                relationship = "Others"
            }
          

            var ben = { Name: name, Address: address, Phone: phone, Dob: dob2, Relationship: relationship, Proportion: proportion, Email: email };

            benficiaries.push(ben);
            addRow2(ben);
            hide = document.getElementById('divstep3');
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
function getLocation(locationid) {
    console.log("i am here in locat");
    var urlFetch = '@Url.Action("Base", "GetLocationbyid")' + '?id=' + locationid;
    $.ajax(urlFetch, {
        success: function (data) {
            console.log("i am here in locat end");
            return data.locdesc;
        },
        error: function () {
           
        }
    });
}
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
        case 3:
            stepname = "Step 3: Beneficiary Information";
            show = document.getElementById('divstep3');
            hide = document.getElementById('divstep4');
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
function addRow2(ben) {
    ShowLoading();
    console.log(ben);
    var table = document.getElementById("tbBen2");
    var tbDiv = document.getElementById('divBen2');
    tbDiv.style.display = "block";

    var tbody = document.getElementById('tbBen2').getElementsByTagName('tbody')[0];
    var rowCount = tbody.rows.length;
    var row = tbody.insertRow(rowCount);
    console.log("Ben2");
    console.log(ben.Name);
    row.insertCell(0).innerHTML = ben.Name;
    row.insertCell(1).innerHTML = ben.Address;
    row.insertCell(2).innerHTML = ben.Phone;
    row.insertCell(3).innerHTML = ben.Email;
    row.insertCell(4).innerHTML = ben.Dob;
    row.insertCell(5).innerHTML = ben.Relationship;
    row.insertCell(6).innerHTML = ben.Proportion;
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
$('#btnstep3Next').click(function () {
    console.log('About to Save Sign Up');
    ShowLoading();
        if (benficiaries.length > 0) {
            if (signUpModel != null || signUpModel != {} || signUpModel !== undefined) {
                //var benJson = JSON.stringify(benficiaries).toString();
                //benficiaries.toString();
                signUpModel.PersonalInfo.Beneficiary = benficiaries;
                console.log(signUpModel);
                postSignUp(3, signUpModel);
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
    console.log('hide loading...');
    HideLoading();

});
$('#btnsubmit').click(function () {
    console.log('About to Save Sign Up');

    //if (window.FormData !== undefined) {
    var uploadfile = $("#PictureFile").get(0);
    var files = uploadfile.files;

    //var formdata = new FormData();
       
    //    for (var i = 0; i < files.length; i++) {
    //        formdata.append(file[i].name, files[i]);
    //    }
    //   //formdata.append('profilepic', "kennth");
    ////   var files = uploadfile.files;
    //console.log(signUpModel.PersonalInfo.PictureFile);
    //console.log(files);


    if ($("#chkcondition").is(':checked')) {
    ShowLoading();
    if (benficiaries.length > 0) {
        if (signUpModel != null || signUpModel != {} || signUpModel !== undefined) {
            //var benJson = JSON.stringify(benficiaries).toString();
            //benficiaries.toString();
            signUpModel.PersonalInfo.Beneficiary = benficiaries;
            var url = $("#step4frm").attr("action");
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
       
    }
    else {
        alert("Please accept term and condition");
        return false;
    }

});

function ShowLoading() {
    $('#ajax').modal({ backdrop: 'static', keyboard: false });
}

function HideLoading() {
    $('#ajax').modal('hide');
}
function AcceptTermAndcondition() {

    if ($("#chkcondition").is(':checked')) {
        return true;
    }
    else {
        alert("Please accept term and condition");
        return false;
    }
}
$('#PictureFile').on('change', function (e) {
    var files = e.target.files;
    var PersonalInfo = $("#step1Frm").serializeObject();
    var myID = PersonalInfo.IdentityNumber; //uncomment this to make sure the ajax URL works
    var fileUpload = $("#PictureFile")[0];
    //var regex = new RegExp("([a-zA-Z0-9\s_\\.\-:])+(.jpg|.png|.gif)$");
    //if (regex.test(fileUpload.value.toLowerCase())) {
        if (typeof (fileUpload.files) != "undefined") {
            var reader = new FileReader();
            reader.readAsDataURL(fileUpload.files[0]);
            reader.onload = function (e) {
                var image = new Image();
                image.src = e.target.result;
                image.onload = function () {
                    var height = this.height;
                    var width = this.width;
                    if (height > 300 || width > 300) {
                        alert("Height and Width must not exceed 300px.");
                        location.reload();
                        return false;
                    }
                   // alert("Uploaded image has valid Height and Width.");
                    return true;
                };
            }
        } else {
            alert("This browser does not support HTML5.");
            return false;
        }
    //} else {
    //    alert("Please select a valid Image file.");
    //    return false;
    //}

    if (files.length > 0) {
        if (window.FormData !== undefined) {
            var data = new FormData();
            for (var x = 0; x < files.length; x++) {
                data.append("file" + x, files[x]);
            }

            $.ajax({
                type: "POST",
                url: '/SignUp/UploadHomeReport?id=' + myID,
                contentType: false,
                processData: false,
                data: data,
                success: function (result) {
                    console.log(result);
                },
                error: function (xhr, status, p3, p4) {
                    var err = "Error " + " " + status + " " + p3 + " " + p4;
                    if (xhr.responseText && xhr.responseText[0] == "{")
                        err = JSON.parse(xhr.responseText).Message;
                    console.log(err);
                }
            });
        } else {
            alert("This browser doesn't support HTML5 file uploads!");
        }
    }
});