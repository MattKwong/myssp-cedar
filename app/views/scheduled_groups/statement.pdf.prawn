prawn_document() do |pdf|
    logopath = ::Rails.root.join('public','logo.png')
    pdf.image logopath, :width => 80, :height => 80

    pdf.text "Statement", :align => :center, :style => :bold, :size => 20
    pdf.text "Sierra Service Project"
    pdf.text "PO Box 992"
    pdf.move_up(16)
    pdf.text "Date: #{Date.today.strftime("%m/%d/%y")}", :align => :right, :style => :bold
    pdf.text "Carmichael, CA 95609"
    pdf.text "916-488-6441"

    pdf.move_down(20)
    pdf.text "Bill To:", :style => :bold
    pdf.text @group.liaison.name
    pdf.text @group.church.name
    pdf.move_up(15)
    pdf.text "Site: #{@group.session.site.name}", :align => :right
    pdf.text @group.church.address1
    pdf.move_up(15)
    pdf.text "Period: #{@group.session.period.name} (#{@group.session.period.start_date.strftime("%m/%d/%y")} - #{@group.session.period.end_date.strftime("%m/%d/%y")})", :align => :right
    pdf.text "#{@group.church.city}, #{@group.church.state} #{@group.church.zip}"
    pdf.move_up(15)
    pdf.text "Group Name: #{@group.name}", :align => :right
    pdf.move_down(30)
    items = Array.new
    i = 0

    items[i] = ["Date", "Description", "Number","Fees", "Total Amount", "Processing Charges"]
    i += 1
    items[i] = [@registration.created_at.strftime("%m/%d/%Y"), "Deposits", @group.overall_high_water, number_to_currency(@group.session.payment_schedule.deposit),
            number_to_currency(@group.deposit_amount), '']
    i += 1
    if @group.second_payment_required
        items[i] = [@group.session.payment_schedule.second_payment_date.strftime("%m/%d/%Y"), "2nd Payments", @group.second_half_high_water, number_to_currency(@group.session.payment_schedule.second_payment),
                    number_to_currency(@group.second_pay_amount), '']
    end
    i += 1
    items[i] = [@group.session.final_payment_date.strftime("%m/%d/%Y"), "Final Payments", @group.current_total, number_to_currency(@group.session.payment_schedule.final_payment),
                number_to_currency(@group.final_pay_amount), '']
    i += 1
    @group.adjustments.each { |a|
        items[i] = [a.created_at.strftime("%m/%d/%Y"), "Adjustment: #{a.adjustment_code.short_name}", "", "", number_to_currency(-a.amount), '']
        i += 1
    }
    items[i] = ['',"Total", "", "", number_to_currency(@group.total_due), '']
    i += 1
    if @group.payments
        @group.payments.each { |p|
            if p.payment_type == "Processing Charge"
                items[i] = [p.payment_date.strftime("%m/%d/%Y"), "Processing Charge", '', '', '', number_to_currency(p.payment_amount)]
            else
                items[i] = [p.payment_date.strftime("%m/%d/%Y"), "Payment: #{p.payment_method}", '', number_to_currency(p.payment_amount), '', '']
            end

            i += 1
        }
    end


    items[i] = ['',"Total Paid to Date", "", "", number_to_currency(-@group.fee_amount_paid), '']
    i += 1
    items[i] = ['',"Second Payment Late Charge", "", "", number_to_currency(@group.second_late_penalty_amount), '']
    i += 1
    if !@group.second_payment_due?
        items[i] = ["Final Payment Late Charge", "", "", number_to_currency(@group.final_late_penalty_amount), '']
        i += 1
    end
    items[i] = ['',"Total Remaining To Be Paid", "", "", number_to_currency(@group.total_balance_due), '']



    pdf.table(items, :header => true,
            :column_widths => {0 => 60, 1 => 130, 2 => 80, 3 => 80, 4 => 80, 5 => 80 },
            :row_colors => ["F0F0F0", "FFFFCC"] ) do
            cells.size = 10
             row(0).style :align => :left
            column(1).style :align => :left
            column(2).style :align => :left
            column(3).style :align => :right
            column(4).style :align => :right
            column(5).style :align => :right
    end

    pdf.move_down(20)
    pdf.text "If you have any questions about this statement call the SSP office at 916-488-6441."
end
