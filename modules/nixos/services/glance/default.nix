{
  lib,
  config,
  libCustom,
  pkgs-unstable,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.services.glance;
  traefikcfg = config.modules.services.traefik;
  news = {
    tech = {
      feeds = [
        {
          url = "https://www.howtogeek.com/feed";
          title = "How To Geek";
          limit = 4;
        }
      ];
      subreddit = ["technology"];
      youtbe = [
        "UCeeFfhMcJa1kjtfZAGskOCA" # TechLinked
        "UCXuqSBlHAE6Xw-yeJA0Tunw" # LinusTechTips
        "UCdBK94H6oZT2Q7l0-b0xmMg" # ShortCircuit
        "UC2ksme4hP4Nx97ilFTQ0K0Q" # Threat Interactive
        "UC0vBXGSyV14uvJ4hECDOl0Q" # Techquickie
      ];
    };
    vulgarization = {
      feeds = [];
      subreddit = [];
      youtbe = [
        "UCHnyfMqiRRG1u-2MsSQLbXA" # Veritasium
      ];
    };
    gamming = {
      feeds = [
        {
          url = "http://feeds.ign.com/ign/all";
          title = "IGN";
          limit = 4;
        }
        {
          url = "https://store.steampowered.com/feeds/news.xml";
          title = "Steam News";
          limit = 4;
        }
        {
          url = "https://www.eurogamer.net/?format=rss";
          title = "Eurogamer";
          limit = 4;
        }
      ];
      subreddit = [
        "games"
        "pcgaming"
        "feedthebeast"
      ];
      youtube = [
        "UCRHXUZ0BxbkU2MYZgsuFgkQ" # The Spiffing Brit
        "UCE-f0sqi-H7kuLT0YiW9rcA" # TheLazyPeon
        "UCE7HSqVe0-fTumbJJn3S5hg" # Lashmak (Minecraft)
        "UCpWEeICUoxrhkjTID4j7-tw" # Threefold (Minecraft)
        "UC18RieOQuuvjWcHADpZqOFQ" # Dan Field
        "UCTR7wxZ_91orxoOXiKr5GDw" # Grind Hard Squad (Warframe)
        "UC0Gx64EmyVDd9gxemldd8Gw" # mbXtreme (POE)
        "UCtaitEe18wjuft1FDV5zcYQ" # SoftGaming
      ];
    };
    electronics = {
      feeds = [
        {
          url = "https://hackaday.com/blog/feed";
          title = "Hackaday";
          limit = 4;
        }
      ];
      subreddit = [];
      youtube = [
        "UCH6ppHEvV3_WIXEwmhv9HEg" # Deus Ex Silicium
        "UCS0N5baNlQWJCUrhCEo8WlA" # Ben Eater
        "UCpOlOeQjj7EsVnDh3zuCgsA" # Adafruit Industries
        "UC3VDCeZYZH7mCihtMVHqppw" # Matt Brown
        "UC3S8vxwRfqLBdIhgRlDRVzw" # stacksmashing
        "UCe3v5cVACw-5BKQOcwUaM8w" # Eric Peronnin
        "UCp5Z7utSI2IHQUsnkPH41bw" # Some Assembly required
      ];
    };
    programation = {
      feeds = [
        {
          url = "https://tratt.net/laurie/news.rss";
          title = "Laurence Tratt";
          limit = 10;
        }
        {
          url = "https://smallcultfollowing.com/babysteps//index.xml";
          title = "Baby Steps";
          limit = 5;
        }
        {
          url = "https://blog.vaxry.net/feed";
          title = "Vaxry's blog";
          limit = 4;
        }
        {
          url = "https://notashelf.dev/rss.xml";
          title = "Notashelf's blog";
          limit = 4;
        }
        {
          url = "https://planet.kernel.org/";
          title = "Planet kernel";
          limit = 4;
        }
        {
          url = "https://engineering.atspotify.com/feed";
          title = "Engineering At Spotify";
          limit = 4;
        }
      ];
      subreddit = [
        "rust"
        "linuxmasterrace"
        "NixOS"
        "cpp"
        "selfhosted"
        "rust_gamedev"
      ];
      youtube = [
        # Top
        "UCYI-TL0LoFRl1gFnnUFwdow" # Better Software Conference
        "UC_zBdZ0_H_jn41FDRG7q4Tw" # VimJoyer
        "UCiDpRjyRpsgRSEM2pIrkCiA" # BitLemon
        "UCGKEMK3s-ZPbjVOIuAV8clQ" # Core Dump
        "UCRq87C6FUHWWaKkImDeMVBw" # Maple Circuit
        "UC2Xd-TjJByJyK2w1zNwY0zQ" # Beyond Fireship
        "UCsBjURrPoezykLs9EqgamOA" # Fireship
        "UCAMu6Dso0ENoNm3sKpQsy0g" # Nir Lichtman
        "UC_XDaRJhEt_LIE3Mp1FYzsA" # Charles Cabergs
        "UCz-yrxeZYIYdpEZgHGvIydA" # Nic Barker
        "UC-4nsAH5j9AIhv5tHoQSP9g" # Interview Pen
        "UC7BL19P9OXPOJgu2DRzozDA" # Eskil Steenberg
        "UCCuoqzrsHlwv1YyPKLuMDUQ" # Jonathan Blow
        "UC8bYucAICXmYet8pZ5Ja9Dw" # Martin Donald
        "UCWQaM7SpSECp9FELz-cHzuQ" # Dreams of Code
        "UCZ7il9AWfJ78UwUuD3daKvg" # Codotaku
        "UC56l7uZA209tlPTVOJiJ8Tw" # Low Byte Productions
        "UCMFbNXUkjSUJ6WC20tGTzJg" # École du Web
        "UCuudpdbKmQWq2PPzYgVCWlA" # Indently
        "UCHkYOD-3fZbuGhwsADBd9ZQ" # Lawrence Systems

        "UCVGuvJBjMyli7v1ggX6Klqg" # Jake Hamilton (Nix)
        "UCnHX5FjwtQpxkCGziuh4NJA" # Logan Smith
        "UCGtVGfQUDGW_plNH7ITSMTQ" # The Dev Method (Rust)
        "UCwq2lyHFTRm4s6iBq8UV5pQ" # Schrödinger's Watermelon (Rust)
        "UCbx9qdxwUUrMxpcPor4nVTA" # MathiasCodes (Rust)
        "UCF6BQExwkd4Fmk1Nx_G6Fmw" # Rust Dublin
        "UCcQWoBTNG__OwfZk9znWgCQ" # The Rusty Bits (Rust-IoT)

        "UCMwLVepB4YOgpyo48iyg7HA" # Vercidium
        "UCnTeNFSWH-Nh-kbXjAznIxw" # Quantale
        "UCdYwjLVP-98bptdlQFO_5zQ" # Inbound Shovel (Game dev)
        "UCRwMQverxgWbv9Yu5aLpQ-w" # Lavafroth
        "UCKWaEZ-_VweaEx1j62do_vQ" # IBM Technology
        "UC4JX40jDee_tINbkjycV4Sg" # Tech With Tim
        "UCYkZbyXcVmtdRUpCBi713vw" # Anton Putra
        "UC5UAwBUum7CPN5buc-_N1Fw" # The Linux Experiment
      ];
    };
    selfhost = {
      feeds = [
        {
          url = "https://selfh.st/rss/";
          title = "selfh.st";
          limit = 4;
        }
      ];
      subreddit = [];
      youtube = [];
    };
    cyber = {
      feeds = [];
      subreddit = [
        "hackthebox"
        "privacy"
      ];
      youtube = [
        "UC7YOGHUfC1Tb6E4pudI9STA" # Mental Outlaw
        "UC6biysICWOJ-C3P4Tyeggzg" # Low Level
      ];
    };
    diy = {
      feeds = [];
      subreddit = [];
      youtube = [
        "UCwivlXhhHxc7c5RAtmpLykw" # Play Conveyor
        "UCEIwxahdLz7bap-VDs9h35A" # Steve Mould
        "UCQ9qxInZTJznj3O18qymalQ" # Christopher's Factory
        "UCdZP_6QvuYiHi4yLufgZUNg" # PLACITECH
        "UCE6HvtWSP-rfVq3bjwU8idw" # Le Bricolage pour les Nuls
      ];
    };
    politics = {
      feeds = [
        {
          url = "https://www.mediapart.fr/articles/feed";
          title = "Mediapart";
          limit = 4;
        }
        {
          url = "https://www.lemonde.fr/rss/une.xml";
          title = "Le Monde";
          limit = 4;
        }
        {
          url = "https://www.ouest-france.fr/rss-en-continu.xml";
          title = "Ouest-France ";
          limit = 4;
        }
      ];
      subreddit = [
        "etudiants"
        "pcgaming"
      ];
      youtube = [
        "UCkgO4A3Fzm5D9Xu1Y_4vCKQ" # Elucid
        "UC__xRB5L4toU9yYawt_lIKg" # Blast
        "UCFemKOoYVrTGUhuVzuNPt4A" # Actu Réfractaire
        "UC9NB2nXjNtRabu3YLPB16Hg" # J'suis pas content TV
        "UCYkZbyXcVmtdRUpCBi713vw" # Pure Politique
        "UCAcAnMF0OrCtUep3Y4M-ZPw" # HugoDécrypte - Actus du jour
        "UCdrC0GnbagXnOrMvFcQS-YA" # Lex Imperii
      ];
    };
  };

  weatherLocationList = [
    "Rennes, France"
    "Lannion, France"
  ];

  searchBangs = [
    # Youtube Bang
    {
      title = "YouTube";
      shortcut = "!yt";
      url = "https://www.youtube.com/results?search_query={QUERY}";
    }
    # Google Bang
    {
      title = "Google";
      shortcut = "!g";
      url = "https://www.google.com/search?q={QUERY}";
    }
    # Wikipedia Bang
    {
      title = "Wikipedia";
      shortcut = "!w";
      url = "https://wikipedia.org/w/index.php?search={QUERY}";
    }
    # Nix Wikipedia Bang
    {
      title = "Nix Wiki";
      shortcut = "!nw";
      url = "https://nixos.wiki/index.php?search={QUERY}";
    }
  ];

  mapRedditWidget = builtins.map (subreddit: {
    inherit subreddit;
    type = "reddit";
    show-thumbnails = true;
    style = "vertical-list";
  });
in {
  options.modules.services.glance = {
    enable = mkEnableOpt "Enable glance homepage";
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      glance = {
        name = "Glance";
        # icon = "services.adguardhome"; # TODO create service extractor
        info = lib.mkForce "Self hosted homepage/dashboard";
      };
    };

    services.traefik = {
      # glance Configuration
      dynamicConfigOptions = {
        http = {
          services.glance.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:8080";
            }
          ];

          routers.glance = {
            rule = "Host(`home.${traefikcfg.domain}`)";
            entryPoints = ["websecure"];
            service = "glance";
            tls = traefikcfg.tlsConfig; # Uses Traefik's default self-signed cert
          };

          # routers.glance = {
          #   entryPoints = [ "websecure" ];
          #   rule = "Host(`${domain}`)";
          #   service = "glance";
          #   tls.certResolver = "letsencrypt";
          # };

          # routers.glanceServerPage = {
          #   entryPoints = [ "websecure" ];
          #   rule = "Host(`${domain}`) && (Path(`/server`) || Path(`/oidc/callback`))";
          #   service = "glance";
          #   tls.certResolver = "letsencrypt";
          #   middlewares = [ "oidc-auth" ];
          # };
        };
      };
    };

    services.glance = {
      enable = true;
      package = pkgs-unstable.glance;
      settings = {
        server.port = 8080;
        branding.custom-footer = ''
          <p>Powered by Glance</p>
        '';
        pages = [
          # Startpage
          {
            name = "Startpage";
            width = "slim";
            # hide-desktop-navigation = true;
            center-vertically = true;
            columns = [
              {
                size = "full";
                widgets = [
                  # Search
                  {
                    type = "search";
                    search-engine = "duckduckgo";
                    autofocus = true;
                    bangs = searchBangs;
                  }
                  {
                    type = "custom-api";
                    title = "Random Fact";
                    cache = "6h";
                    url = "https://uselessfacts.jsph.pl/api/v2/facts/random";
                    template = ''
                      <p class="size-h4 color-paragraph">{{ .JSON.String "text" }}</p>
                    '';
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "General";
                        links = [
                          {
                            title = "Gmail";
                            url = "https://mail.google.com/mail/u/0/";
                          }
                          {
                            title = "Github";
                            url = "https://github.com/";
                          }
                          {
                            title = "Amazon";
                            url = "https://www.amazon.com/";
                          }
                          {
                            title = "Aliexpress";
                            url = "https://aliexpress.com/";
                          }
                        ];
                      }
                      {
                        title = "University";
                        links = [
                          {
                            title = "Moodle";
                            url = "https://foad.univ-rennes.fr/my/";
                          }
                          {
                            title = "Planning";
                            url = "https://planning.univ-rennes1.fr/direct/myplanning.jsp";
                          }
                          {
                            title = "Intranet ESIR";
                            url = "https://esir.univ-rennes.fr/intranet-general-etudiants-et-personnels";
                          }
                          {
                            title = "Gitlab ESIR";
                            url = "https://gitlab2.istic.univ-rennes1.fr/";
                          }
                        ];
                      }
                      {
                        title = "Entertainment";
                        links = [
                          {
                            title = "YouTube";
                            url = "https://www.youtube.com/";
                          }
                          {
                            title = "Prime Video";
                            url = "https://www.primevideo.com/";
                          }
                          {
                            title = "JellyFin";
                            url = "https://media.cloud.tolok.org";
                          }
                        ];
                      }
                      {
                        title = "Developement";
                        links = [
                          {
                            title = "Home Manager Options";
                            url = "https://nix-community.github.io/home-manager/options.xhtml";
                          }
                          {
                            title = "Nixos Search";
                            url = "https://search.nixos.org/packages";
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          }

          # Server Info dodo handle this based on the allowed services
          # {
          #   name = "Server";
          #   columns = [
          #     {
          #       size = "full";
          #       widgets = [
          #         # Services
          #         {
          #           type = "monitor";
          #           cache = "1m";
          #           title = "Services";
          #           sites = tolokServices;
          #         }
          #       ];
          #     }
          #   ];
          # }

          # Home Page
          # > Calendar, Weather, Small Video, Small RSS, ...
          {
            name = "Home";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "releases";
                    cache = "1d";
                    repositories = [
                      "glanceapp/glance"
                      "go-gitea/gitea"
                      "immich-app/immich"
                      "syncthing/syncthing"
                    ];
                  }
                  # TODO Display statistics from a self-hosted ad-blocking DNS resolver such as AdGuard Home or Pi-hole.
                  # {
                  #   type = "dns-stats";
                  #   service = "adguard";
                  #   username = "admin";
                  #   password = "\${ADGUARD_PASSWORD}"; # From Env
                  #   url = "https://adguard.domain.com/";
                  # }
                  {
                    type = "custom-api";
                    title = "Steam Specials";
                    cache = "12h";
                    url = "https://store.steampowered.com/api/featuredcategories?cc=us";
                    template = ''
                      <ul class="list list-gap-10 collapsible-container" data-collapse-after="5">
                      {{ range .JSON.Array "specials.items" }}
                        <li>
                          <a class="size-h4 color-highlight block text-truncate" href="https://store.steampowered.com/app/{{ .Int "id" }}/">{{ .String "name" }}</a>
                          <ul class="list-horizontal-text">
                            <li>{{ div (.Int "final_price" | toFloat) 100 | printf "$%.2f" }}</li>
                            {{ $discount := .Int "discount_percent" }}
                            <li{{ if ge $discount 40 }} class="color-positive"{{ end }}>{{ $discount }}% off</li>
                          </ul>
                        </li>
                      {{ end }}
                      </ul>
                    '';
                  }
                  {
                    type = "twitch-channels";
                    channels = [
                      "theprimeagen"
                      "j_blow"
                      "piratesoftware"
                      "cohhcarnage"
                      "christitustech"
                      "EJ_SA"
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  # Search Bang
                  {
                    type = "search";
                    search-engine = "duckduckgo";
                    autofocus = false;
                    bangs = searchBangs;
                  }
                  # Reddit
                  {
                    type = "group";
                    widgets = mapRedditWidget (
                      news.programation.subreddit
                      ++ news.tech.subreddit
                      ++ news.electronics.subreddit
                      ++ news.politics.subreddit
                      ++ news.diy.subreddit
                    );
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "Usefull Links";
                        links = [
                          {
                            title = "Icons";
                            url = "https://selfh.st/icons/";
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "clock";
                  }
                  {
                    type = "calendar";
                    first-day-of-week = "monday";
                  }
                  {
                    type = "group";
                    widgets =
                      builtins.map (location: {
                        inherit location;
                        type = "weather";
                        units = "metric";
                        hour-format = "24h";
                      })
                      weatherLocationList;
                  }
                ];
              }
            ];
          }
          # Media Content news
          # > Youtube Video
          {
            name = "Prog";
            columns = [
              {
                size = "small";
                widgets = [
                  # News Widgets
                  {
                    type = "group";
                    widgets = [
                      {type = "hacker-news";}
                      {type = "lobsters";}
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  # Large Youtube Video Grid
                  {
                    type = "videos";
                    channels =
                      news.programation.youtube
                      ++ news.electronics.youtube
                      ++ news.selfhost.youtube
                      ++ news.cyber.youtube;
                    style = "grid-cards";
                    collapse-after-rows = 3;
                  }
                  # Reddit
                  {
                    type = "group";
                    widgets = mapRedditWidget (
                      news.programation.subreddit
                      ++ news.electronics.subreddit
                      ++ news.selfhost.subreddit
                      ++ news.cyber.subreddit
                    );
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  # RSS Feeds
                  {
                    type = "rss";
                    limit = 20;
                    collapse-after = 10;
                    cache = "12h";
                    style = "vertical-lis";
                    feeds =
                      news.programation.feeds ++ news.electronics.feeds ++ news.selfhost.feeds ++ news.cyber.feeds;
                  }
                ];
              }
            ];
          }

          # Gamming
          # > Youtube Twitch Reddit
          {
            name = "Gaming";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "twitch-top-games";
                    limit = 20;
                    collapse-after = 13;
                    exclude = [
                      "just-chatting"
                      "pools-hot-tubs-and-beaches"
                      "music"
                      "art"
                      "asmr"
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "videos";
                    channels = news.gamming.youtube;
                    style = "grid-cards";
                    collapse-after-rows = 3;
                  }
                  {
                    type = "group";
                    widgets = mapRedditWidget (news.gamming.subreddit);
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "rss";
                    limit = 20;
                    collapse-after = 10;
                    cache = "12h";
                    style = "vertical-lis";
                    feeds = news.gamming.feeds;
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
