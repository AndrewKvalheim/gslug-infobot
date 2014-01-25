module InfoBot
  module Resources
    # Generic template to be rendered
    class Resource
      def initialize path
        @pathname ||= Pathname.new(path)
      end

      def path
        @pathname.to_s
      end
    end

    # Local file to generate from a template
    class LocalFile < Resource
      def initialize path, build_path
        @build_path ||= build_path

        super path
      end

      def destination_path
        @build_path + @pathname.basename('.erb')
      end
    end

    # Wiki page to generate from a template
    class WikiPage < Resource
      def title
        @pathname.basename('.wiki.erb').to_s
      end
    end
  end
end
