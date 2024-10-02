Hackler::Engine.routes.draw do
  post "enqueue", to: "job#enqueue", constraints: ->() { Hackler.worker }
  post "work",    to: "job#work",    constraints: ->() { !Hackler.worker }
end
