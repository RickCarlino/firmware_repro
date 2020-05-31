import Config

config :firmware_repro, target: Mix.target()

# https://hexdocs.pm/nerves/advanced-configuration.html
config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves, source_date_epoch: "1590933859"

config :logger, backends: [RingLogger]

if Mix.target() != :host do
  import_config "target.exs"
end
