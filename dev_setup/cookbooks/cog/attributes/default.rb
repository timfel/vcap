include_attribute "deployment"
default[:cog][:version] = "4.0"
default[:cog][:source] = "http://www.mirandabanda.org/files/Cog/VM/VM.r2522/cogmtlinux.tgz"
default[:cog][:path] = File.join(node[:deployment][:home], "deploy", "cog")
