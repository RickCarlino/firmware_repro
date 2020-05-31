defmodule FirmwareRepro do
  @uart_speed 115_200
  @max_attempts 4
  @tty_path "/dev/ttyAMA0"
  require Logger

  def hex_path do
    Application.app_dir(:firmware_repro, ["priv", "express_k10.hex"])
  end

  def reset() do
    gpio_module = Circuits.GPIO
    {:ok, gpio} = gpio_module.open(19, :output)
    :ok = gpio_module.write(gpio, 0)
    :ok = gpio_module.write(gpio, 1)
    Process.sleep(1100)
    :ok = gpio_module.write(gpio, 0)
    gpio_module.close(gpio)
  end

  def default_args do
    [
      "-patmega2560",
      "-cwiring",
      "-P#{@tty_path}",
      "-b#{@uart_speed}",
      "-D",
      "-V",
      "-v",
      "-Uflash:w:#{hex_path()}:i"
    ]
  end

  def flash() do
    _ = File.stat!(hex_path())
    call_avr_dude(default_args())
  end

  def call_avr_dude(args, attempts \\ 1) do
    reset()
    {msg, exit_code} = MuonTrap.cmd("avrdude", args, stderr_to_stdout: true)
    give_up? = attempts > @max_attempts
    Logger.info("==== Attempts: #{attempts}")
    Logger.info("==== exit code: #{exit_code}")
    Logger.info("==== Output:")
    Logger.info(msg)

    if exit_code == 0 || give_up? do
      {msg, exit_code}
    else
      call_avr_dude(args, attempts + 1)
    end
  end
end
