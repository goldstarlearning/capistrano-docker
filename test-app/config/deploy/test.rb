server ENV["APP_SERVER"],
       user: "deploy",
       roles: %w{app web}

server ENV["BUILD_SERVER"],
       user: "deploy",
       roles: %w{build},
       primary: true
