module Dune
  module Stanzas
    class RoasterGet < IQ

      matcher -> n {
        n.name == 'iq' && n['type'] == 'get' && n.xpath('ns:query', 'ns' => NAMESPACES[:roster]).any?
      }

      def response
        contacts = @stream.server.storage.get_roster(@stream.user.jid)

        iq 'result' do |el, doc|
          el << doc.create_element('query', xmlns: NAMESPACES[:roster], ver: contacts.hash) do |query|
            contacts.each do |contact|
              query << doc.create_element('item', jid: contact.jid.bare, name: contact.name, subscription: contact.state) do |item|
                contact.groups.each do |group|
                  item << doc.create_element('group', group)
                end
              end
            end
          end
        end
      end
    end
  end
end
