var liaison_id
var group_type;
var group_type_name;
var requested_youth = 0;
var requested_adults = 0;
var total_requested = 0;
var site_choice=[];
var week_choice=[];
var session_choices=[0,0,0,0,0,0,0,0,0,0];
var session_choices_names=['','','','','','','','','',''];
var number_of_choices;
var amount_paid;
var payment_tracking_number;
var table_html;
var comments;
var info_table;
var enrollment_html;
var choice_html;

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
    $("#submit_first").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#submit_first').click(function(){
        liaison_id = $("td#liaison_id").text();
        //update progress bar
        $('#progress_text').html('14% Complete');
        $('#progress').css('width','50px');
        //slide steps
        $('#first_step').slideUp();
        $('#second_step').slideDown();
    });
});

// Second step routines
$(document).ready(function() {
    $("#submit_second").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $("#back_second").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#submit_second').click(function(){
        //save the group type
        group_type = $("input[name=group_type]:checked").val();

        //ajax call to get group limits and appropriate text
        $.get("get_limit_info?value="+ group_type,
            function(data){ $("#limit_info").html(data);} );
        group_type_name = $("input[name=group_type_name]").val();
        info_table = '' ;
        info_table+= "<tr><td>Group Type</td><td>";
        info_table += group_type_name;
        info_table += "</td></tr>";
//        $("#info_table_third").html(info_table);

        //update progress bar

        $('#progress_text').html('28% Complete');
        $('#progress').css('width','100px');
        //slide steps
        $('#second_step').slideUp();
        $('#third_step').slideDown();
    });
});
$(document).ready(function() {
    $('#back_second').click(function(){
        //update progress bar
        $('#progress_text').html('0% Complete');
        $('#progress').css('width','0px');
        //slide steps
        $('#second_step').slideUp();
        $('#first_step').slideDown();
    });
});


$(document).ready(function() {
    $("#submit_third").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $("#back_third").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#submit_third').click(function(){
        //ajax call to get sites that are hosting group_type of groups
        $.get("get_sites_for_group_type?value="+ group_type,
            function(data){ $("#site_selector").html(data);} );

        $('#site_info').html($('input[name=site_text]').val());
//        enrollment_html = '';
//        enrollment_html+= "<tr><td>Total Requested</td><td>";
//        enrollment_html += total_requested;
//        enrollment_html += "</td></tr>";
//        $("#info_table_fourth").html(info_table + enrollment_html);
        group_type_name = $("input[name=group_type_name]").val();

        //update progress bar
        $('#progress_text').html('44% Complete');
        $('#progress').css('width','150px');
        //slide steps
        $('#third_step').slideUp();
        $('#fourth_step').slideDown();
    });
});
$(document).ready(function() {
    $('#back_third').click(function(){
        //update progress bar
        $('#progress_text').html('14% Complete');
        $('#progress').css('width','50px');
        //slide steps
        $('#third_step').slideUp();
        $('#second_step').slideDown();
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
            $.get("get_sessions_for_type_and_site?value="+ group_type + "&site="+ $("#site_selector_site_id").val(),
                function(data){ $("#session_selector").html(data);})
        }
    );
});

$(document).ready(function() {
    $('#submit_fourth').click(function(){

        //save the choices
        site_choice[0] = $("#site_selector_site_id").val();
        week_choice[0] = $("#session_selector_session_id").val();

        number_of_choices = 0

        //get and show the remaining site choices
        //also returns selection array to hidden field
        $.get("get_alt_sites_for_group_type?value="+ group_type + "&session_choices=" + session_choices
            + "&session_choices_names=" + session_choices_names
            + "&current_site=" + site_choice[0] + "&current_week=" + week_choice[0] + "&number_of_choices=" + number_of_choices
            ,
            function(data){ $("#alt_site_selector").html(data);}
        );
//        choice_html = '';
//        choice_html+= "<tr><td>Choice 1:</td><td>";
////        choice_html += $("input[name=session_choices_names]").val().split('/')[0];
//        choice_html += "</td></tr>";
//        $("#info_table_fifth").html(info_table + enrollment_html + choice_html);
        //update progress bar
        $('#progress_text').html('60% Complete');
        $('#progress').css('width','200px');
        //slide steps
        $('#fourth_step').slideUp();
        $('#fifth_step').slideDown();
    });
});

$(document).ready(function() {
    $("#alt_site_selector").change(function(){
            $.get("get_alt_sessions_for_type_site?value="+ group_type
                + "&site="+ $("#alt_site_selector_site_id").val()
                + "&session_choices=" + $("input[name=session_choices]").val().split('/')
                + "&session_choices_names=" + $("input[name=session_choices_names]").val().split('/')
                + "&current_site=" + site_choice[0]
                + "&current_week=" + week_choice[0]
                + "&number_of_choices=" + number_of_choices
                ,
                function(data){ $("#alt_session_selector").html(data);})
        }
    );
});

$(document).ready(function() {
    $("#submit_fourth").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $("#back_fourth").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $('#back_fourth').click(function(){
        //update progress bar
        $('#progress_text').html('28% Complete');
        $('#progress').css('width','100px');
        //slide steps
        $('#fourth_step').slideUp();
        $('#third_step').slideDown();
    });
});

$(document).ready(function() {
    $('#add_choice').click(function(){

        session_choices= $("input[name=session_choices]").val();
        session_choices_names = $("input[name=session_choices_names]").val();
        number_of_choices++;
        site_choice = $("#alt_site_selector_site_id").val();
//        alert(site_choice);
//        site_choice[0] = $("input[name=site_name]").val();
//        week_choice[0] = $("input[name=week_name]").val();
        week_choice = $("#alt_session_selector_session_id").val();


        //get and show the remaining site choices
        //also returns selection array to hidden field
        $.get("get_alt_sites_for_group_type?value="+ group_type + "&session_choices=" + session_choices
            + "&session_choices_names=" + session_choices_names
            + "&current_site=" + site_choice + "&current_week=" + week_choice + "&number_of_choices=" + number_of_choices
            ,
            function(data){ $("#alt_site_selector").html(data);}
        );
        session_choices= $("input[name=session_choices]").val();
        session_choices_names = $("input[name=session_choices_names]").val();
        $('#fifth_step').slideUp();
        $('#fifth_step').slideDown();
    });
});


$(document).ready(function() {
    $('#submit_fifth').click(function(){
    //update progress bar
        $('#progress_text').html('74% Complete');
        $('#progress').css('width','250px');
    // slide steps
        $('#fifth_step').slideUp();
        $('#sixth_step').slideDown();
    });
});


$(document).ready(function() {
    $("#submit_fifth").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $("#add_choice").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $("#back_fifth").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $('#back_fifth').click(function(){
        //update progress bar
        $('#progress_text').html('48% Complete');
        $('#progress').css('width','250px');
        //slide steps
        $('#fifth_step').slideUp();
        $('#fourth_step').slideDown();
    });
});
$(document).ready(function() {
    $("#back_sixth").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#back_sixth').click(function(){

        //update progress bar
        $('#progress_text').html('60% Complete');
        $('#progress').css('width','200px');
        //slide steps
        $('#sixth_step').slideUp();
        $('#fifth_step').slideDown();
    });
});


$(document).ready(function() {
    $('#submit_sixth').click(function(){
        comments = $("textarea#registration_comments").val()
        session_choices= $("input[name=session_choices]").val().split('/');
        session_choices_names = $("input[name=session_choices_names]").val().split('/');
        table_html = '' ;
        table_html += "<tr><td>Group Type</td><td>";
        table_html += group_type_name;
        table_html += "</td></tr>";
        table_html += "<tr><td>Youth</td><td>";
        table_html += requested_youth;
        table_html += "</td></tr>";
        table_html += "<tr><td>Counselors</td><td>";
        table_html += requested_adults;
        table_html += "</td></tr>";
        table_html += "<tr><td>Total</td><td>";
        table_html += total_requested;
        table_html += "</td></tr>";
        $.each(session_choices_names, function(index, value) {
            table_html += "<tr><td>Choice "
            table_html += index + 1;
            table_html += "</td><td>"
            table_html += value;
            table_html += "</td></tr>";
        });
        table_html += "<tr><td>Special Comments</td><td>";
        table_html += comments;
        table_html += "</td></tr>";
        $('#request_info_table').html(table_html)
        //update progress bar
        $('#progress_text').html('86% Complete');
        $('#progress').css('width','300px');
        //slide steps
        $('#sixth_step').slideUp();
        $('#seventh_step').slideDown();
    });
});

$(document).ready(function() {
    $("#back_seventh").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $("#submit_seventh").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $('#back_seventh').click(function(){
        //update progress bar
        $('#progress_text').html('60% Complete');
        $('#progress').css('width','200px');
        //slide steps
        $('#seventh_step').slideUp();
        $('#sixth_step').slideDown();
    });
});


$(document).ready(function() {
    $('#submit_seventh').click(function(){
        //Send the data to the server and create the new registration record
        $.get("save_registration_data?group_type="+ group_type + "&session_choices=" + session_choices
            + "&comments=" + comments + "&requested_youth=" + requested_youth + "&requested_adults="
            + requested_adults + "&liaison_id=" + liaison_id );
        //update progress bar
        $('#progress_text').html('86% Complete');
        $('#progress').css('width','300px');
        //slide steps
        $('#seventh_step').slideUp();
        $('#eighth_step').slideDown();
    });
});

$(document).ready(function() {
    $('#submit_eighth').click(function(){

        table_html += "<tr><td>Amount paid</td><td>";
        table_html += amount_paid;
        table_html += "</td></tr>";
        table_html += "<tr><td>Receipt id</td><td>";
        table_html += payment_tracking_number;
        table_html += "</td></tr>";


        $('#final_registration_table').append(table_html)

        //update progress bar
        $('#progress_text').html('100% Complete');
        $('#progress').css('width','350px');
        //slide steps
        $('#eighth_step').slideUp();
        $('#ninth_step').slideDown();
    });
});
