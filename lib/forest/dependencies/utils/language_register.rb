class Forest
  module LanguageRegister
    def register_language(language)
      @languages ||= {}
      check_new_language(language)
      @languages.merge!(language)
    end

    def languages
      @languages
    end

    private

    def check_new_language(language)
      common_keys = @languages.keys & language.keys
      return if common_keys.empty?

      common_key = common_keys.first
      error = "Lanugage with the extension '#{common_key}' " +
        "can't be registerd because the same extension " +
        "is already registered. " +
        "Here's the already registered language: " + "#{@languages[common_key].inspect} " +
        "and here's the language that was about to be registered: " +
        "#{language[common_key].inspect}."
      raise error
    end
  end
end
