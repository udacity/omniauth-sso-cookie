require 'omniauth'
require 'base64'
require 'openssl'
require 'json'

module OmniAuth
  module Strategies
    class SsoCookie
      include OmniAuth::Strategy

      option :uid_field, :email
      option :login_url
      option :cookie_name
      option :encryption_key
      option :hmac_key

      def request_phase
        auth_cookie = request.cookies[options.cookie_name]
        begin
          auth_cookie = SsoCookie.
            decrypt_cookie(auth_cookie, options.encryption_key, options.hmac_key) \
            unless auth_cookie.nil?
        rescue
          self.log(:warn, "Error decoding '#{auth_cookie}'")
          auth_cookie = nil
        end
        if auth_cookie.nil?
          redirect options.login_url
        else
          redirect callback_url
        end
      end

      uid do
        auth_cookie = request.cookies[options.cookie_name]
        data = SsoCookie.decrypt_cookie(auth_cookie, options.encryption_key, options.hmac_key)
        data[options.uid_field]
      end

      info do
        auth_cookie = request.cookies[options.cookie_name]
        SsoCookie.decrypt_cookie(auth_cookie, options.encryption_key, options.hmac_key)
      end

      def SsoCookie.decrypt_cookie(cookie, encryption_key, hmac_key)
        data = Base64.strict_decode64(cookie)
        prefix, data, hmac = data[0..2], data[3..-33], data[-32..-1]
        target_hmac  = OpenSSL::HMAC.digest('sha256', hmac_key, data)
        if !SsoCookie.constant_time_comparison(hmac, target_hmac)
          fail("Authentication error!")
        end
        if prefix == '$2$'
          iv, data = data[0..15], data[16..-1]
          cipher = OpenSSL::Cipher.new('aes-256-cbc')
          cipher.decrypt
          cipher.key = encryption_key
          cipher.iv = iv
          decrypted = cipher.update(data) << cipher.final()
        elsif prefix == '$1$'
          decrypted = data
        else
          fail("Unhandled prefix! (#{prefix})")
        end
        result = JSON.parse(decrypted)
        result['expires'].to_i <= Time.now.to_i ? nil : result
      end

      def SsoCookie.constant_time_comparison(a, b)
        check = a.bytesize ^ b.bytesize
        a.bytes.zip(b.bytes) { |x, y| check |= x ^ y.to_i }
        return check == 0
      end
    end
  end
end
