var liaison_id;
var group_type;
var group_type_name;
var requested_youth = 0;
var requested_adults = 0;
var total_requested = 0;
var site_choice;
var week_choice;
var session_choices = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
var session_choices_names=['','','','','','','','','',''];
var number_of_choices;
var registration_id;
var amount_paid;
var payment_tracking_number;
var table_html;
var comments;
var deposit_amount;
var processing_charge = 0;
var to_be_charged;
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
        $('#progress_text').html('12.5% Complete');
        $('#progress').css('width','42.5px');
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
        //remove classes
        $('#second_step').removeClass('error').removeClass('valid');
        var error = 0;
        //save the group type
        group_type = $("input[name=group_type]:checked").val();
        if( group_type == undefined) {
            $('#error_text_group').html('Error: You must select a group type.');
            error++
        } else {
            $("#second_step").addClass('valid');
        }

    if(!error){
        //ajax call to get group limits and appropriate text
        $.get("get_limit_info?value="+ group_type,
            function(data){ $("#limit_info").html(data);} );
        group_type_name = $("input[name=group_type_name]").val();
        $("#registration_requested_youth").val=0;


        //update progress bar

        $('#progress_text').html('25% Complete');
        $('#progress').css('width','85px');
        //slide steps
        $('#second_step').slideUp();
        $('#third_step').slideDown();
    } else {
        return false;
    }
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
        //remove classes
        $('#third_step').removeClass('error').removeClass('valid');
        var error = 0;
        var group_limit = $("input[name=group_limit]").val();
        if( total_requested > parseInt(group_limit) ) {
            $('#error_text_numbers').html('Error: You may not request more than ' + group_limit + ' total spots.');
            error++
        }
        if( !error && requested_youth < 1 || requested_adults < 1 ) {
            $('#error_text_numbers').html('Error: You must request at least 1 counselor and 1 youth spots.');
            error++
        }

        if(!error) {
            $("#third_step").addClass('valid');
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
        $('#progress_text').html('37.5% Complete');
        $('#progress').css('width','132px');
        //slide steps
        $('#third_step').slideUp();
        $('#fourth_step').slideDown();
        } else {
            return false
        }
    });
});
$(document).ready(function() {
    $('#back_third').click(function(){
        //update progress bar
        $('#progress_text').html('12.5% Complete');
        $('#progress').css('width','42.5px');
        //slide steps
        $('#third_step').slideUp();
        $('#second_step').slideDown();
    });
});

$(document).ready(function() {
    $("#registration_requested_youth").change(function(){
        if (isNaN($("#registration_requested_youth").val())) {
            requested_youth = 0;
            alert("You must only input valid numbers here.")
        } else {
            requested_youth = parseInt($("#registration_requested_youth").val());
            total_requested = requested_youth + requested_adults;
            $('#requested_total').html(total_requested);}
        }
    );
});
$(document).ready(function() {
    $("#registration_requested_counselors").change(function(){
        if (isNaN($("#registration_requested_counselors").val())) {
            requested_adults = 0;
            alert("You must only input valid numbers here.")
        } else {
            requested_adults = parseInt($("#registration_requested_counselors").val());
            total_requested = requested_youth + requested_adults;
            $('#requested_total').html(total_requested);}
        }
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
        if ($("#site_selector_site_id").val() == undefined) {
            site_choice = ''
        } else {
            site_choice = $("#site_selector_site_id").val();
        }

        if ($("#session_selector_session_id").val() == '') {
            week_choice = ''
        } else {
            week_choice = $("#session_selector_session_id").val();
        }

        number_of_choices = 0;

        var error = 0;
        if( site_choice == '' || week_choice == '') {
            $('#error_text_selections').html('Error: You must select a valid site and a week.');
            error++
        }

        if( !error) {
            //get and show the remaining site choices
            //also returns selection array to hidden field
            $.get("get_alt_sites_for_group_type?value="+ group_type + "&session_choices=" + session_choices
                + "&session_choices_names=" + session_choices_names
                + "&current_site=" + site_choice + "&current_week=" + week_choice + "&number_of_choices=" + number_of_choices
                ,
                function(data){ $("#alt_site_selector").html(data);
//                }
//            );
            session_choices = $("input[name=session_choices_names]").val().split('/')
            session_count = $("input[name=session_count]").val();
            choice_html = '';
            choice_html += "<tr><td>Current Choices</td></tr>";
            choice_html += "<tr><td>Choice " + parseInt(session_count + 1) + ": </td><td>";
            choice_html += session_choices[0];
            choice_html += "</td></tr>";
            $("#prev_choices_table5").html(choice_html);
//            update progress bar
            $('#progress_text').html('50% Complete');
            $('#progress').css('width','170px');
            //slide steps
            $('#fourth_step').slideUp();
            $('#fifth_step').slideDown();
                }
            );
        } else {
            return false
        }
    });
});

$(document).ready(function() {
    $("#alt_site_selector").change(function(){
            $.get("get_alt_sessions_for_type_site?value="+ group_type
                + "&site="+ $("#alt_site_selector_site_id").val()
                + "&session_choices=" + $("input[name=session_choices]").val().split('/')
                + "&session_choices_names=" + $("input[name=session_choices_names]").val().split('/')
                + "&number_of_choices=" + number_of_choices
                ,
                function(data){ $("#alt_session_selector").html(data);
//                alert(data);
                })
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
        $('#progress_text').html('25% Complete');
        $('#progress').css('width','85px');
        //slide steps
        $('#fourth_step').slideUp();
        $('#third_step').slideDown();
    });
});

$(document).ready(function() {
    $('#add_choice').click(function(){

        session_choices= $("input[name=session_choices]").val();
        session_choices_names = $("input[name=session_choices_names]").val();

        site_choice = $("#alt_site_selector_site_id").val();
        week_choice = $("#alt_session_selector_session_id").val();
//        alert('site_choice is ' + site_choice)
//        alert('week_choice is ' + week_choice)
        var error = 0;
        if( site_choice == '' || week_choice == '') {
            $('#error_text_alt_selections').html('Error: You must select a valid site and a week.');
            error++
        }

        if(!error) {
//            alert('number of choices is ' + number_of_choices);
            number_of_choices++;
            $.get("get_alt_sites_for_group_type?value="+ group_type + "&session_choices=" + session_choices
                + "&session_choices_names=" + session_choices_names
                + "&current_site=" + site_choice + "&current_week=" + week_choice + "&number_of_choices=" + number_of_choices
                ,
                function(data){ $("#alt_site_selector").html(data);

            session_choices = $("input[name=session_choices_names]").val().split('/');
            session_count = $("input[name=session_count]").val();
//            alert('session_count returned is ' + session_count);
            choice_html = '';
            choice_html += "<tr><td>Current Choices</td></tr>";
            $.each(session_choices, function(index, value) {
                choice_html += "<tr><td>Choice " + (index + 1) + ": </td><td>";
                choice_html += value;
                choice_html += "</td></tr>";
            });
            $("#prev_choices_table5").html(choice_html);
            $('#error_text_alt_selections').html('');
            $('#fifth_step').slideUp();
            $('#fifth_step').slideDown();
                });
        } else {
            return false
        }

    });
});


$(document).ready(function() {
    $('#submit_fifth').click(function(){
        $("#prev_choices_table6").html(choice_html);
    //update progress bar
        $('#progress_text').html('62.5% Complete');
        $('#progress').css('width','212px');
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
        $('#error_text_selections').html('');
        $('#progress_text').html('37.5% Complete');
        $('#progress').css('width','228px');
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
        $('#progress_text').html('50% Complete');
        $('#progress').css('width','170px');
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
        $('#progress_text').html('75% Complete');
        $('#progress').css('width','265px');
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
    $('#back_seventh').click(function(){
        //update progress bar
        $('#progress_text').html('62.5% Complete');
        $('#progress').css('width','212px');
        //slide steps
        $('#seventh_step').slideUp();
        $('#sixth_step').slideDown();
    });
});

$(document).ready(function() {
    $("#submit_seventh").addClass('disabled');
//    $("#submit_seventh").removeAttr('onclick');
});

$(document).ready(function() {
    $('#pay_by_check').click(function(){
        //Finalize without using payment gateway.
        amount_paid = 0;
        payment_tracking_number = "None";

        //Send the confirming email and update the payment information
        //retrieve the registration id
        registration_id = $("input[name=registration_id]").val();

        $.get("pay_by_check?reg_id=" + registration_id
            + "&amount_paid=" + amount_paid + "&deposit_amount=" + deposit_amount + "&payment_tracking_number="
            + payment_tracking_number);

        table_html += "<tr><td>Deposit Amount Due</td><td>";
        table_html += "$" + deposit_amount;
        table_html += "<tr><td>Amount Paid</td><td>";
        table_html += "$" + amount_paid;
        table_html += "</td></tr>";
        table_html += "<tr><td>Receipt id</td><td>";
        table_html += payment_tracking_number;
        table_html += "</td></tr>";


        $('#final_registration_table').append(table_html)

        //update progress bar
        $('#progress_text').html('100% Complete');
        $('#progress').css('width','340px');
        //slide steps
        $('#eighth_step').slideUp();
        $('#ninth_step').slideDown();
    });
});

$(document).ready(function() {
    $("#print_ninth").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#print_ninth').click(function(){
        //Print the page
        window.print();
    });
});
$(document).ready(function() {
    $("#pay_by_cc").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $("#pay_by_check").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $("#pay_now").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $("#back_gateway").hover(function() {
        $(this).addClass('hover');
    });
});
$(document).ready(function() {
    $('#pay_by_cc').click(function(){
        //Pull the deposit_amount and processing_charge

        deposit_amount = $("input[name=deposit_amount]").val();
        processing_charge = $("input[name=processing_charge]").val();
        to_be_charged = (parseFloat(deposit_amount));
        $("#processing_label").html("Include the 2.9% Credit Card Charge that SSP Pays ($" + parseFloat($("input[name=processing_charge]").val()).toFixed(2) + ")");
        $("td#disp_deposit_amount").html("$" + parseFloat(deposit_amount).toFixed(2));
        $("td#processing_charge").html('');
        $("td#to_be_charged").html("$" + to_be_charged.toFixed(2));
        //update progress bar
        $('#progress_text').html('87.5% Complete');
        $('#progress').css('width','308px');
        $('#eighth_step').slideUp();
        $('#gateway_step').slideDown();

    });
});

$(document).ready(function() {
    $('input[name=include_charge]').click(function(){
        //Pull the deposit_amount and processing_charge
            if ($(this).is(':checked')) {
                processing_charge = $("input[name=processing_charge]").val();
            } else {
                processing_charge = 0; }

//        alert(processing_charge);
        to_be_charged = (parseFloat(deposit_amount) + parseFloat(processing_charge));

        $("td#disp_deposit_amount").html("$" + parseFloat(deposit_amount).toFixed(2));
        $("td#processing_charge").html("$" + parseFloat(processing_charge).toFixed(2));
        $("td#to_be_charged").html("$" + to_be_charged.toFixed(2));
        //update progress bar
        $('#progress_text').html('87.5% Complete');
        $('#progress').css('width','308px');
        $('#eighth_step').slideUp();
        $('#gateway_step').slideDown();

    });
});

$(document).ready(function() {
    $('#back_gateway').click(function(){
        $('#gateway_step').slideUp();
        $('#eighth_step').slideDown();
    });
});

$(document).ready(function() {
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
});

function stripeDepositResponseHandler(status, response) {
    if (response.error) {
        // re-enable the submit button
        $('#pay_now').removeAttr("disabled");
        // show the errors on the form
            $("#payment_errors").html(response.error.message);
    } else {
        // token contains id, last4, and card type
        var token = response['id'];
        // and submit
//        alert(processing_charge);
        registration_id = $("input[name=registration_id]").val();
        $.get("process_cc_dep_payment?reg_id=" + registration_id  + "&deposit_amount=" + deposit_amount
            + "&amount_paid=" + to_be_charged + "&processing_charge=" + processing_charge + "&payment_tracking_number="
            + token,  function(data) {

            $("#gateway_data").html(data);
            var error_message = $("input[name=gateway_error]").val();
            if (error_message) {
                $("#payment_errors").html(error_message);
            } else {
                table_html += "<tr><td>Deposit Amount</td><td>";
                table_html += "$" + parseFloat(deposit_amount).toFixed(2);
                table_html += "<tr><td>Processing Charge</td><td>";
                table_html += "$" + parseFloat(processing_charge).toFixed(2);
                table_html += "<tr><td>Amount paid</td><td>";
                table_html += "$" + parseFloat(to_be_charged).toFixed(2);
                table_html += "</td></tr>";
                table_html += "<tr><td>Receipt id</td><td>";
                table_html += token;
                table_html += "</td></tr>";
                $('#final_registration_table').append(table_html);

                //update progress bar
                $('#progress_text').html('100% Complete');
                $('#progress').css('width','340px');
                //slide steps
                $('#gateway_step').slideUp();
                $('#ninth_step').slideDown();
            };

        });

    };
}

$(document).ready(function() {
    $("#pay_now").click(function(event) {
        // disable the submit button to prevent repeated clicks
        $('#pay_now').attr("disabled", "disabled");
        // createToken returns immediately - the supplied callback submits the form if there are no errors

        Stripe.createToken({
            number: $('.card-number').val(),
            cvc: $('.card-cvc').val(),
            exp_month: $('.card-expiry-month').val(),
            exp_year: $('.card-expiry-year').val()
        }, stripeDepositResponseHandler);
        return false; // submit from callback
    });
});

$(document).ready(function() {
    $("#request_link").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $("#request_link").click(function() {
        $.get("request_matrix",  function(data) {
            $('#request_data').html(data);
            $('#request_data').modal();
            $('#request_data').addClass("hidden")
        });
    });
});

$(document).ready(function() {
    $("#available_link").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $("#available_link").click(function() {
        $.get("availability_matrix",  function(data) {
            $('#available_data').html(data);
            $('#available_data').modal();
            $('#available_data').addClass("hidden")
        });
    });
});

function submitSeventh() {
//        alert("submitSeventh was clicked");
            //Send the data to the server and create the new registration record
        $.get("save_registration_data?group_type="+ group_type + "&session_choices=" + session_choices
            + "&comments=" + comments + "&requested_youth=" + requested_youth + "&requested_adults="
            + requested_adults + "&liaison_id=" + liaison_id, function(data) {
            $("#step_seven_data").html(data);
            deposit_amount = parseInt($("input[name=deposit_amount]").val());
        } );


        //update progress bar
        $('#progress_text').html('75% Complete');
        $('#progress').css('width','265px');
        //slide steps
        $('#seventh_step').slideUp();
        $('#eighth_step').slideDown();

}

$(document).ready(function() {
    $('input[name=accept_terms]').click(function(){
        //Enable the confirm button if checked
        if ($(this).is(':checked')) {
            $("#submit_seventh").removeClass('disabled');
            $("#submit_seventh").bind('click', submitSeventh);
            $("#submit_seventh").hover(function() {
                $(this).addClass('hover');
           });
        } else {
            $("#submit_seventh").addClass('disabled');
            $("#submit_seventh").unbind('click', submitSeventh);
            $("#submit_seventh").hover(function() {
                $(this).removeClass('hover');
            });
        }
    });
});




