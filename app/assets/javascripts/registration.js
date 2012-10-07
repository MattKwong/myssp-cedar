
var group_type;
var requested_youth = 0;
var requested_adults = 0;
var total_requested;
var max_group_size;
var group_size_text;

////inputfocus
//$('input#username').inputfocus({ value: field_values['group_type'] });
//$('input#password').inputfocus({ value: field_values['requested_youth'] });
//    $('input#cpassword').inputfocus({ value: field_values['requested_counselors'] });
//    $('input#lastname').inputfocus({ value: field_values['site_selection'] });
//$('input#firstname').inputfocus({ value: field_values['session_selection'] });

//reset progress bar

$('#progress').css('width','0');
$('#progress_text').html('0% Complete');

//first_step
//$(document).ready('form').submit(function(){ return false; });

$(document).ready(function() {
    $("#submit_first img").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#submit_first img').click(function(){

        //update progress bar
        $('#progress_text').html('12.5% Complete');
        $('#progress').css('width','50px');
        //slide steps
        $('#first_step').slideUp();
        $('#second_step').slideDown();
    });
});
$(document).ready(function() {
    $("#submit_second img").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#submit_second img').click(function(){
//        alert($("input[name=group_type]:checked").val())
        //ajax call to get group limits and appropriate text
        $.get("get_limit_info?value="+ $("input[name=group_type]:checked").val(),
            function(data){ $("#limit_info").html(data)
//                , alert(parseInt($("input[name=group_limit]").val()))
            ;}

        );
        //update progress bar
        $('#progress_text').html('25% Complete');
        $('#progress').css('width','100px');
        //slide steps
        $('#second_step').slideUp();
        $('#third_step').slideDown();
    });
});


$(document).ready(function() {
    $("#submit_third img").hover(function() {
        $(this).addClass('hover');
    });

});

$(document).ready(function() {
    $('#submit_third img').click(function(){
        //ajax call to get sites that are hosting group_type of groups
        $.get("get_sites_for_group_type?value="+ $("input[name=group_type]:checked").val(),
            function(data){ $("#site_selector").html(data);} )

        //update progress bar
        $('#progress_text').html('37.5% Complete');
        $('#progress').css('width','150px');
        //slide steps
        $('#third_step').slideUp();
        $('#fourth_step').slideDown();
    });
});

$(document).ready(function() {
    $("#registration_requested_youth").change(function(){
        requested_youth = parseInt($("#registration_requested_youth").val());
        total_requested = requested_youth + requested_adults;
        $('#requested_total').html(total_requested);}
    );
});
$(document).ready(function() {
    $("#registration_requested_counselors").change(function(){
        requested_adults = parseInt($("#registration_requested_counselors").val());
        total_requested = requested_youth + requested_adults;
        $('#requested_total').html(total_requested);}
    );
});
$(document).ready(function() {
    $("#site_selector").change(function(){
            $.get("get_sessions_for_type_and_site?value="+ $("input[name=group_type]:checked").val() + "&site="+ $("#site_selector_site_id").val(),
                function(data){ $("#session_selector").html(data);},
        alert($("#site_selector_site_id").val()));}
    );
});
