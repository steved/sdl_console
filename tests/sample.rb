Dir.chdir(File.expand_path(File.dirname(__FILE__)))

require 'sdl'
require 'console'

SDL.init(SDL::INIT_VIDEO)
SDL::TTF.init

font = SDL::TTF.open("sample.ttf", 20)
screen = SDL::setVideoMode(800, 600, 0, SDL::DOUBLEBUF)
SDL::Key.enableKeyRepeat(500, 30)

console = Console.new(screen, font, font.height * 6)
console.active = true

while true
  while event = SDL::Event2.poll
    case event
    when SDL::Event2::KeyDown
      console.keypress?(event)
    when SDL::Event2::Quit
      exit
    end
  end

  screen.fillRect(0, 0, 800, 600, 0)

  console.draw if console.active

  screen.flip
end
