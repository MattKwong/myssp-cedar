$(document).ready(function() {
    $('<div id="loading">Retrieving data...please be patient!</div>')
        .insertBefore("#active_admin_content")
        .ajaxStart(function() {
            $(this).show()
            $('body').css('cursor', 'progress');
//            $(this).addClass('wait');

        }).ajaxStop(function() {
            $(this).hide();
            $('body').css('cursor', 'default');
        });
});

$(document).ready(function() {
    $("#spending-link").click(function(){
//             $.get("get_spending_info?startDate="+$("#startDate").val()+"?endDate="+$("#endDate").val(),
//                function(data){ $("#spending-table").html(data);} )
        $.get("get_spending_info" , { startDate: $("#startDate").val(), endDate: $("#endDate").val() },
            function(data){ $("#spending-table").html(data);} )


    });
});