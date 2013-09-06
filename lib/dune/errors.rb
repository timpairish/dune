module Dune
  class XmppError < StandardError
    include Nokogiri::XML

    # Returns the XML element name based on the exception class name.
    # For example, Dune::BadFormat becomes bad-format.
    def element_name
      name = self.class.name.split('::').last
      name.scan(/[A-Z][^A-Z]*/).join('-').downcase
    end
  end

  class SaslError < XmppError
    def initialize(text = nil)
      @text = text
    end

    def to_xml
      doc = Document.new
      doc.create_element('failure') do |node|
        node.add_namespace(nil, NAMESPACES[:sasl])
        node << doc.create_element(element_name)
        if @text
          node << doc.create_element('text') do |text|
            text['xml:lang'] = 'en'
            text.content = @text
          end
        end
      end.to_xml(:indent => 0).gsub(/\n/, '')
    end
  end

  class StreamError < XmppError

    def initialize(text = nil)
      @text = text
    end

    def to_xml
      doc = Document.new
      doc.create_element('stream:error') do |el|
        el << doc.create_element(element_name, 'xmlns' => NAMESPACES[:streams])
        if @text
          el << doc.create_element('text', @text, 'xmlns' => NAMESPACES[:streams], 'xml:lang' => 'en')
        end
      end.to_xml(indent: 0).gsub(/\n/, '')
    end
  end

  class StanzaError < XmppError
    TYPES = %w[auth cancel continue modify wait]
    KINDS = %w[message presence iq]

    def initialize(el, type, text = nil)
      raise "type must be one of: #{ TYPES.join ', ' }" unless TYPES.include?(type)
      raise "stanza must be one of: #{KINDS.join ', ' }" unless KINDS.include?(el.name)
      @stanza_kind = el.name
      @type = type
      @text = text
      @id = el['id']
      @from = el['from']
      @to = el['to']
    end

    def to_xml
      doc = Document.new
      doc.create_element(@stanza_kind) do |el|
        el['from'] = @to   if @to
        el['id']   = @id   if @id
        el['to']   = @from if @from
        el['type'] = 'error'
        el << doc.create_element('error', 'type' => @type) do |error|
          error << doc.create_element(element_name, 'xmlns' => NAMESPACES[:stanzas])
          if @text
            error << doc.create_element('text', @text, 'xmlns' => NAMESPACES[:stanzas], 'xml:lang' => 'en')
          end
        end
      end.to_xml(indent: 0).gsub(/\n/, '')
    end
  end

  module SaslErrors
    class Aborted < SaslError; end
    class AccountDisabled < SaslError; end
    class CredentialsExpired < SaslError; end
    class EncryptionRequired < SaslError; end
    class IncorrectEncoding < SaslError; end
    class InvalidAuthzid < SaslError; end
    class InvalidMechanism < SaslError; end
    class MalformedRequest < SaslError; end
    class MechanismTooWeak < SaslError; end
    class NotAuthorized < SaslError; end
    class TemporaryAuthFailure < SaslError; end
  end

  module StreamErrors
    class BadFormat < StreamError; end
    class BadNamespacePrefix < StreamError; end
    class Conflict < StreamError; end
    class ConnectionTimeout < StreamError; end
    class DefinedCondition < StreamError; end
    class HostGone < StreamError; end
    class HostUnknown < StreamError; end
    class ImproperAddressing < StreamError; end
    class InternalServerError < StreamError; end
    class InvalidFrom < StreamError; end
    class InvalidNamespace < StreamError; end
    class InvalidXml < StreamError; end
    class NotAuthorized < StreamError; end
    class NotWellFormed < StreamError; end
    class PolicyViolation < StreamError; end
    class RemoteConnectionFailed < StreamError; end
    class Reset < StreamError; end
    class ResourceConstraint < StreamError; end
    class RestrictedXml < StreamError; end
    class SeeOtherHost < StreamError; end
    class SystemShutdown < StreamError; end
    class UndefinedCondition < StreamError; end
    class UnsupportedEncoding < StreamError; end
    class UnsupportedFeature < StreamError; end
    class UnsupportedStanzaType < StreamError; end
    class UnsupportedVersion < StreamError; end
  end

  module StanzaErrors
    class BadRequest < StanzaError; end
    class Conflict < StanzaError; end
    class FeatureNotImplemented < StanzaError; end
    class Forbidden < StanzaError; end
    class Gone < StanzaError; end
    class InternalServerError < StanzaError; end
    class ItemNotFound < StanzaError; end
    class JidMalformed < StanzaError; end
    class NotAcceptable < StanzaError; end
    class NotAllowed < StanzaError; end
    class NotAuthorized < StanzaError; end
    class PolicyViolation < StanzaError; end
    class RecipientUnavailable < StanzaError; end
    class Redirect < StanzaError; end
    class RegistrationRequired < StanzaError; end
    class RemoteServerNotFound < StanzaError; end
    class RemoteServerTimeout < StanzaError; end
    class ResourceConstraint < StanzaError; end
    class ServiceUnavailable < StanzaError; end
    class SubscriptionRequired < StanzaError; end
    class UndefinedCondition < StanzaError; end
    class UnexpectedRequest < StanzaError; end
  end
end
