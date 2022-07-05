function ShowLoading() {
    $('#ajax').modal({ backdrop: 'static', keyboard: false });
};

function HideLoading() {
    $('#ajax').modal('hide');
};

function showModal(data, title,fn) {
    //$('modalbody').html(data);
    alert("i am here")
    var modalbody = document.getElementById('modalbody');
    modalbody.innerHTML = data;
    console.log(data)
    modalbody.focus();
    alert("i am here")
    //var ppp = document.getElementById('PolType').value;
    //console.log(ppp);

    var modaltitle = document.getElementById('title');
    modaltitle.innerText = title;
    var submitbtn = document.getElementById('modalSubmit');
    submitbtn.setAttribute("data-click", fn);
    submitbtn.setAttribute("onclick", fn);
    if (fn == '') {
        document.getElementById('modal-footer').style.display = 'none';
    }

    if (title==='Rate') {
        //document.getElementById("rateRules").style.display = "none";
        var ppp = document.getElementById('PolType').value;
        console.log(ppp);
       

        document.getElementById('PolType').addEventListener('change', function (event) {
            var poltype = event.target.value;
            console.log(poltype);
            if (poltype === 'PP2') {
                document.getElementById('rateRulesPPP').style.display = 'block'
                document.getElementById('rateRules').style.display='none'
            }
        })
    }

  
    //submitbtn.onclick=fn;
    $('#Modal').modal({ backdrop: 'static', keyboard: false });

};

function showModalfromfile(url, title, fn) {
    $('#modalbody').load(url);
    var modaltitle = document.getElementById('title');
    modaltitle.innerText = title;
    var submitbtn = document.getElementById('modalSubmit');
    submitbtn.setAttribute("data-click", fn);
    submitbtn.setAttribute("onclick", fn);
    $('#Modal').modal({ backdrop: 'static', keyboard: false });

};

function hideModal(Isclose) {
    var modalbody = document.getElementById('modalbody');
    if (Isclose) {
        modalbody.innerHTML = "";
    }
    $('#Modal').modal('hide');
};

function SubmitModal(el) {
    var f = $(el).attr('data-click')
    var func = new Function(f);
};

function LoadDropDown(el,url,data,defaultText) {
    var url = url;
    var data = data;
    var promise = $.post(url, data, function (data) {    //ajax call
        var items = [];
        items.push("<option value=" + 0 + ">" + defaultText + "</option>"); //first item
        for (var i = 0; i < data.length; i++) {
            items.push("<option value=" + data[i].Value + ">" + data[i].Text + "</option>");
        }                                         //all data from the team table push into array
        $(el).html(items.join(' '));
    });
    return promise;
}

function ValidateInput(container) {
    var isValid = true;
    var fields;
    if (container != null || container != '' || container !== undefined) {
        fields = $(container + ' .ss-item-required').find('select,textarea,input').serializeArray();
    } else {
        fields = $('.ss-item-required').find('select,textarea,input').serializeArray();
    }

    $.each(fields, function (i, field) {
        if (!field.value) {
            toastr.error(field.name + " required", "Validation Error");
            isValid = false;
        }
    });
    return isValid;

}

function base64ToArrayBuffer (base64) {
    var binaryString = window.atob(base64);
    var binaryLen = binaryString.length;
    var bytes = new Uint8Array(binaryLen);
    for (var i = 0; i < binaryLen; i++) {
        var ascii = binaryString.charCodeAt(i);
        bytes[i] = ascii;
    }
    return bytes;
}
function saveByteArray() {
    var a = document.createElement("a");
    document.body.appendChild(a);
    a.style = "display: none";
    return function (data, name) {
        var blob = new Blob(data, { type: "octet/stream" }),
            url = window.URL.createObjectURL(blob);
        a.href = url;
        a.download = name;
        a.click();
        window.URL.revokeObjectURL(url);
    };
}

var options = {
    source: function (request, response) {
        $.ajax({
            url: applicationBaseUrl + "/CustPolicy/PolicynoAutoComplete",
            type: "POST",
            dataType: "json",
            data: { query: request.term },
            success: function (data) {
                response($.map(data, function (item) {
                    //$('#policyno').val(item.value)
                    return { label: item.label, value: item.value };
                }));

            }
        });
    },
    select: function (event, ui) {
        AutoCompleteSelectHandler(event, ui);
    }
    //focus: function (event, ui) {
    //    console.log('on focus' + ui);
    //    event.preventDefault();
    //    $('#policyno').val(ui.item.label);
    //},
};
var selector = 'input#policyno'//$("#policyno");//[data-autocomplete='true']
$(document).on('keydown.autocomplete', selector, function () {
    $(this).autocomplete(options);
});

function AutoCompleteSelectHandler(event, ui) {
    console.log(ui);
    var selectedObj = ui.item;
    console.log(selectedObj.value);
    $('#policyno').val(selectedObj.label);
}
