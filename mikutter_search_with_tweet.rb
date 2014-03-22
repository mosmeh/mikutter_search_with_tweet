# -*- coding: utf-8 -*-

Plugin.create :search_with_tweet do
  counter = gen_counter 1

  command(:search_with_tweet,
          name: 'このTweetの本文で検索',
          icon: Skin.get('search.png'),
          condition: Plugin::Command[:HasMessage],
          visible: true,
          role: :timeline) do |opt|
    opt.messages.each do |m|
      serial = counter.call
      slug = "search#{serial}".to_sym
      tab(slug, "検索 \"#{m.to_s}\"") do
        set_deletable true
        set_icon Skin.get("search.png")

        timeline slug do
          order do |message|
            message[:created].to_i
          end
        end
      end

      Service.primary.search(q: m.to_s, rpp: 100).next{|res|
        if res.is_a? Array
          if res.length > 0
            timeline(slug) << res
          else
            timeline(slug) << Message.new(message: 'ツイートが見つかりませんでした', system: true)
          end
        end
      }.trap{|e| timeline(slug) << Message.new(message: "検索中にエラーが発生しました (#{e.to_s})", system: true) }

      timeline(slug).active!
    end
  end
end
