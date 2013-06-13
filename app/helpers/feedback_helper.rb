module FeedbackHelper
  def feedb_table_header
    capture_haml do
      haml_tag :thead do
        haml_tag :th, 'Date'
        haml_tag :th, 'To'
        haml_tag :th, 'Message'
        haml_tag :th, 'Tag'
        haml_tag :th, 'Sent On'
        haml_tag :th, 'System Response'
      end
    end
  end

  def feedb_table_row msg
    capture_haml do
      haml_tag :tr, :class => ('respond' + (msg.sent_on ? ' ' : ' error')) do
        haml_tag :td, (%[%s ago (%s)] % [time_ago_in_words(msg.created_at), msg.created_at])
        haml_tag :td do
          su  = SystemUser.find_by_number(msg.number)
          sp  = SystemUser.find_by_number(msg.number)
          if su then
            %[%s (%s)] % [link_to(su.name, users_path(su.id)), link_to(msg.number, messaging_path(msg.number))]
          else
            if sp then
              %[%s [%]] % [link_to(sp.name, sups_path(sp.id)), link_to(msg.number, messaging_path(msg.number))]
            else
              link_to msg.number, messaging_path(msg.number)
            end
          end
        end
        haml_tag :td, msg.message
        haml_tag :td, msg.tag
        haml_tag :td, (msg.sent_on ? %[%s (%s ago)] % [msg.sent_on, time_ago_in_words(msg.sent_on)] : '')
        haml_tag :td, msg.system_response
      end
    end
  end
end
