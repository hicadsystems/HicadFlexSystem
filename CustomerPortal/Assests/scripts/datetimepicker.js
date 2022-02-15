//$(function () {
//    $('.datepicker').datepicker({
//        format: 'yyyy-mm-dd',
//        autoclose: true
//    }).on('changeDate', function () {
//        $(this).blur();
//    });
//});

function openDatePicker(el) {
    jQuery(document).trigger("date_picker");
    $(el).parent().siblings('.datepicker').trigger('focus')
}

$('div .datepicker').on('changeDate', function (e) {
    //console.log(e);
    $('.datepicker').datepicker('hide');
    //$(this).blur();
    //e.autoclose = true;
    //e.hide;
});
jQuery(document).trigger("date_picker");
$('#myModal').on('show.bs.modal', function () {
    jQuery(document).trigger("date_picker");
})
jQuery('#Modal').trigger("date_picker");

jQuery(document).on("date_picker", function () {
    jQuery("div .datepicker").datepicker({
        format: 'yyyy-mm-dd',
        autoclose: true,
        changeYear: true,
        changeMonth: true,
        dateFormat: "yyyy-mm-dd",
        beforeShow: function () { $('#Modal').maxZIndex(); },
        yearRange: '1940:2030'
    })
    .on('changeDate', function () {
        $('.datepicker').datepicker('hide');
        //$(this).blur();
    });
});

